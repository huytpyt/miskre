class UserService
  def generate_ref_code
    SecureRandom.uuid
  end

  def self.update_paid_status current_user
    customer = Stripe::Customer.retrieve(current_user.customer_id)
    invoice = customer.invoices&.first
    if invoice.present?
      User.update(is_paid: invoice&.paid, period_end: Time.at(invoice&.lines&.first&.period&.end))
    end
  end

  def self.add_new_balance params, user
    amount = params[:amount].to_f
    if amount <= 0
      errors = "Amount must be greater than 0"
      return ["Failed", amount, user, errors, user.balance.total_amount]
    end

    begin
      begin
        @response_result = Stripe::Charge.create(amount: (amount*100).to_i, currency: "usd", description: "Add balance #{amount}$ for user id-#{user.id} email-#{user.email}", customer: user.customer_id)
      rescue Exception => e
        return ["Failed", amount, user, e.message.to_s]
      end
      ActiveRecord::Base.transaction do
        if @response_result.status == "succeeded"
          if user.balance.blank?
            new_balance = Balance.new(
              total_amount: amount
            )
            new_balance.lock!
            user.balance = new_balance
          else
            @user_balance = user.balance
            @user_balance.lock!
            @user_balance.total_amount += amount
            @user_balance.save
          end
          if user.save
            invoice = generate_invoice(user, amount, "", user.balance.total_amount, "deposit")
          end
          fee = Stripe::BalanceTransaction.retrieve(@response_result&.balance_transaction).fee.to_f/100
          if fee > 0
            @user_balance = user.balance
            @user_balance.lock!
            @user_balance.total_amount -= fee
            @user_balance.save
            if user.save
              invoice = generate_invoice(user, -fee, "", user.balance.total_amount, "deposit_fee")
            end
          end
        end
      end
      return [@response_result.status, amount, user, nil, user.reload.balance.total_amount]
    rescue Exception => e
      return [@response_result.status, amount, user, e.message.to_s, user.balance&.total_amount]
    end
  end

  def self.add_balance_manual params
    user = User.find_by_id params[:user_id]
    amount = params[:amount].to_f
    if amount <= 0
      errors = "Amount must be greater than 0"
      return ["Failed", amount, user, errors, user&.balance&.total_amount]
    end

    unless user.present?
      errors = "User not present"
      return ["Failed", amount, user, errors, nil]
    else
      unless user.user?
        errors = "User don't have balance"
        return ["Failed", amount, user, errors, nil]
      else
        ActiveRecord::Base.transaction do
          if user.balance.blank?
            new_balance = Balance.new(
              total_amount: amount
            )
            new_balance.lock!
            user.balance = new_balance
          else
            @user_balance = user.balance
            @user_balance.lock!
            @user_balance.total_amount += amount
            @user_balance.save!
          end
          if user.save!
            invoice = generate_invoice(user, amount, "Added from admin", user.balance, "transfer")
          end
        end
        return ["Succeeded", amount, user, nil, user.reload.balance.total_amount]
      end
    end
  rescue Exception => e
    return ["Failed", amount, user, e.message.to_s, user&.balance&.total_amount]
  end

  def self.refund_balance params
    user = User.find_by_id params[:user_id]
    amount = params[:amount].to_f
    if amount <= 0
      errors = "Amount must be greater than 0"
      return ["Failed", amount, user, errors, user&.balance&.total_amount]
    end

    unless user.present?
      errors = "User not present"
      return ["Failed", amount, user, errors, nil]
    else
      unless user.user?
        errors = "User don't have balance"
        return ["Failed", amount, user, errors, nil]
      else
        ActiveRecord::Base.transaction do
          if user.balance.blank?
            errors = "User don't have balance"
            return ["Failed", amount, user, errors, nil]
          else
            @user_balance = user.balance
            @user_balance.lock!
            @user_balance.total_amount += amount
            @user_balance.save!
          end
          if user.save!
            invoice = generate_invoice(user, amount, "Refunded from admin", user.balance, "refund")
          end
        end
        return ["Succeeded", amount, user, nil, user.reload.balance.total_amount]
      end
    end
  rescue Exception => e
    return ["Failed", amount, user, e.message.to_s, user&.balance&.total_amount]
  end

  def self.request_charge_orders order_list_id, user
    orders_list = Order.where(id: JSON.parse(order_list_id))
    user_balance = user.balance
    if user_balance.nil?
      return { result: "Failed", errors: "You do not have any balance, please add." }
    end

    amount_must_paid = orders_list.inject(0){ |sum_amount, order| sum_amount += OrderService.new.sum_money_from_order(order).to_f }
    user_balance.lock!
    if amount_must_paid > user_balance.total_amount
      return { result: "Failed", errors: "Your account does not have enough balance" }
    end

    if orders_list.pluck(:paid_for_miskre).include?(true)
      return { result: "Failed", errors: "Some of orders had paid" }
    end

    new_request_charge = RequestCharge.new(
      user_id: user.id,
      total_amount: amount_must_paid
    )
    new_request_charge.orders << orders_list
    if new_request_charge.save
      new_request_charge.pending!
      return { request_charge: "completed", errors: nil }
    elsif !new_request_charge.valid?
      return { request_charge: "error", errors: new_request_charge.errors }
    end
  end

  def self.create user_params
    new_user = User.new(user_params)
    ref_code = UserService.new.generate_ref_code
    new_user.reference_code = ref_code unless User.exists?(reference_code: ref_code)

    if new_user.valid?
      new_user.save
    else
      return [ "Failed", new_user.errors.messages, new_user]
    end
    return [ "Success", nil, new_user ]
  end

  def self.update user_id, user_params
    user = User.where(id: user_id).first
    if user
      user.assign_attributes(user_params)
      if user.valid?
        user.save
        return [ "Success", nil, user]
      else
        [ "Failed", user.errors.messages, user]
      end
    else
      return [ "Failed", "Can not find user with id #{user_id}", nil]
    end
  end

  def self.destroy user_id
    user = User.where(id: user_id).first
    if user
      user.destroy
      return [ "Success", nil, nil]
    else
      [ "Failed", "Can not find user with id #{user_id}", nil ]
    end
  end

  def self.accept_new_product shopify_product_id
    supply = Supply.find_by_shopify_product_id shopify_product_id
    supply.is_deleted = false
    supply.save
  end

  private
    def self.generate_invoice user, amount, memo, balance, invoice_type
      invoice = Invoice.create(
          user_id: user.id,
          money_amount: amount,
          memo: memo,
          balance: balance,
          invoice_type: Invoice::invoice_types[invoice_type]
      )
    end
end