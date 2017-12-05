class OrderService
  def sum_money_from_order order
    shop = order.shop
    skus_array = order.skus.split(",").map {|a| a.split("*")[0].strip}
    quantities = order.skus.split(",").map {|a| a.split("*")[1].strip}
    shipping_method = order.shipping_method.upcase
    ship_country =  ISO3166::Country.find_by_name(order.ship_country)[0]
    nation = Nation.find_by_code ship_country
    shipping_type = nation&.shipping_types&.find_by_code shipping_method
    index = 0
    sum = 0
    if shipping_type.present?
      skus_array.each do |sku|
        product = Product.find_by_sku(sku.first(3))
        if product.present?
          user = shop.user
          shipping_cost = CarrierService.cal_cost(shipping_type, product.weight)
          supply_cost = product.cus_cost
          sum += (quantities[index].to_i * (supply_cost + shipping_cost))
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

  def pay_for_miskre order_list_id, user_id
    reponse_result = []
    Order.where(id: order_list_id).inject(0) do |amount, order|
      amount += OrderService.new.sum_money_from_order(order).to_f
      begin
        if order.paid_for_miskre != "succeeded"
          reponse = Stripe::Charge.create(
            customer: (User.find user_id).customer_id,
            amount: (amount*100).to_i,
            currency: "usd"
          )
          reponse_result << { order_id: order.id, status: "succeeded", errors: nil }
        end
      rescue Exception => e
        reponse_result << { order_id: order.id, status: "failed", errors: e.message.to_s}
      end
    end
    [reponse_result, @total_amount_success]
  end
end