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
      errors = "Amount must me greater than 0"
      return ["failed", amount, user, errors, user.balance.total_amount]
    end

    begin
      @response_result = Stripe::Charge.create(
        amount: (amount*100).to_i,
        currency: "usd",
        description: "Add balance #{amount}$ for user id-#{user.id} email-#{user.email}",
        customer: user.customer_id
      )
      ActiveRecord::Base.transaction do
        if @response_result.status == "succeeded"
          if user.balance.blank?
            new_balance = Balance.new(
              total_amount: amount
            )
            user.balance = new_balance
          else
            @user_balance = user.balance
            @user_balance.total_amount += amount
            @user_balance.save
          end
        end
        user.save
      end
      return [@response_result.status, amount, user, nil, user.reload.balance.total_amount]
    rescue Exception => e
      return [@response_result.status, amount, user, e.message.to_s, user.balance.total_amount]
    end
  end
end