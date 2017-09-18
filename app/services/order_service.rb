class OrderService
  def sum_money_from_order order
    quantities = order.skus.split(",").map {|a| a.split("*")[1]}
    prices = order.unit_price.split(",")
    index = 0
    sum = 0
    quantities.each do |quantity|
      sum += (quantity.to_i * prices[index].to_f)
      index += 1
    end
    return sum
  end

  def sum_money_per_bill bill_id
    bill = Billing.find bill_id
    total_money = 0
    bill.orders.each do |order|
      total_money += sum_money_from_order(order)
    end
    return total_money
  end
end