class SupplyService
  def update_fulfillable_quantity_descrease items_array_sku, shop_id
    items_array_sku.each do |item|
      update_fulfillable_quantity_each_item item[:sku], item[:quantity], shop_id
    end
  end

  def update_fulfillable_quantity_each_item sku, quantity, shop_id
    product = Product.find_by_sku(sku&.first(3))
    if product.present?
      supply = product.supplies.find_by_shop_id shop_id
      if supply.present?
        fulfillable_quantity = (supply&.fulfillable_quantity || 0) - quantity.to_i
        supply.update(fulfillable_quantity: fulfillable_quantity)
      end
    end
  end

  def update_fulfilable_quantity_increase sku, quantity, shop_id
    product = Product.find_by_sku(sku&.first(3))
    if product.present?
      supply = product.supplies.find_by_shop_id shop_id
      if supply.present?
        fulfillable_quantity = (supply&.fulfillable_quantity || 0) + quantity.to_i
        supply.update(fulfillable_quantity: fulfillable_quantity)
      end
    end
  end
end