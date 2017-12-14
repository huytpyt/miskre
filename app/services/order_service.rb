class OrderService
  def sum_money_from_order order
    shop = order.shop
    skus_array = order.skus.split(",").map {|a| a.split("*")[0].strip}
    quantities = order.skus.split(",").map {|a| a.split("*")[1].strip}
    shipping_method = order.shipping_method.upcase
    country = ISO3166::Country.find_by_name(order.ship_country)
    ship_country =  country.present? ? country[0] : "US"
    nation = Nation.find_by_code ship_country
    shipping_type = (nation&.shipping_types&.find_by_code shipping_method) || ShippingType.first
    index = 0
    sum = 0
    if shipping_type.present?
      skus_array.each do |sku|
        product = Product.find_by_sku(sku.first(3))
        if product.present?
          user = shop.user
          shipping_cost = CarrierService.cal_cost(shipping_type, product.weight)
          supply_cost = product.cus_cost
          sum += (quantities[index].to_i * (supply_cost.to_f + shipping_cost.to_f))
          index += 1
        end
      end
    end
    return sum.round(2)
  end

  def sum_money_per_bill bill_id
    bill = Billing.find bill_id
    total_money = 0
    bill.orders.each do |order|
      total_money += sum_money_from_order(order)
    end
    return total_money
  end

  def accept_charge_orders request_charge_id
    reponse_result = []
    request_charge = RequestCharge.find request_charge_id
    ActiveRecord::Base.transaction do
      @error = []
      user = request_charge.user
      order_list_id = request_charge.orders.pluck(:id)
      order_list = Order.where(id: order_list_id)

      user_balance = user.balance
      user_balance.lock!
      if user_balance.nil?
        @error << "This user does not have any balance."
        raise ActiveRecord::Rollback
      end

      amount_must_paid = request_charge.total_amount
      if request_charge.pending? && !orders_paid?(order_list)
        if amount_must_paid <= user_balance.total_amount
          new_user_balance = user.balance.total_amount - amount_must_paid
          user_balance.total_amount = new_user_balance
          user_balance.save!
          request_charge.approved!
          order_list.update_all(paid_for_miskre: true)
          generate_invoice_for_orders(user, -amount_must_paid, order_list, "", new_user_balance)
        else
          @error << "This account does not have enough balance"
        end
      else
        @error << "Some of orders had paid or rejected"
      end
    end
    if @error.blank?
      ["OK", request_charge.total_amount, nil]
    else
      ["Failed", 0, @error]
    end
  rescue Exception => error
    ["Failed", 0, error]
  end

  def reject_charge_orders request_charge_id
    request_charge = RequestCharge.find request_charge_id
    if request_charge.approved?
      return { result: "Failed", errors: "This order is approved." }
    else
      request_charge.rejected!
      return { result: "Success", errors: nil }
    end
  end

  private
    def generate_invoice_for_orders user, amount, orders, memo, balance
      invoice = Invoice.create(
        user_id: user.id,
        money_amount: amount,
        memo: memo,
        balance: balance
      )
      invoice.orders << orders
      invoice.order_pay!
    end

    def orders_paid? order_list
      order_list.pluck(:paid_for_miskre).include?(true)
    end
end