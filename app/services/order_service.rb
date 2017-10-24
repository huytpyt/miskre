class OrderService
  def sum_money_from_order order
    shop = order.shop
    skus_array = order.skus.split(",").map {|a| a.split("*")[0].strip}
    quantities = order.skus.split(",").map {|a| a.split("*")[1].strip}
    shipping_method = order.shipping_method.upcase
    ship_country =  ISO3166::Country.find_by_name(order.ship_country)[0] || "US"
    index = 0
    sum = 0
    skus_array.each do |sku|
      product = Product.find_by_sku(sku.first(3))
      supply = product.supplies.find_by_shop_id(shop.id)

      if shipping_method == "DHL"
        cal_weight = (product.length * product.height * product.width) / 5
        weight = cal_weight > product.weight ? cal_weight : product.weight
        cost = CarrierService.get_dhl_cost(ship_country, weight)
      elsif shipping_method == "EPUB"
        cost = CarrierService.get_epub_cost(ship_country, product.weight)
      else
        cost = CarrierService.get_epub_cost(ship_country, product.weight)
      end
      sum += (quantities[index].to_i * (supply.cost + cost))
      index += 1
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
end