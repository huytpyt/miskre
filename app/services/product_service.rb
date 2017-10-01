class ProductService
  def update_fulfillable_quantity_descrease items_array_sku
    items_array_sku.each do |item|
      update_fulfillable_quantity_each_item item[:sku], item[:quantity]
    end
  end

  def update_fulfillable_quantity_each_item sku, quantity
    product = Product.find_by_sku(sku.first(3))
    unless product.nil?
      fulfillable_quantity = (product.fulfillable_quantity || 0) - quantity.to_i
      product.update(fulfillable_quantity: fulfillable_quantity)
    end
  end

  def update_fulfilable_quantity_increase sku, quantity
    product = Product.find_by_sku(sku.first(3))
    fulfillable_quantity = (product.fulfillable_quantity || 0) + quantity.to_i
    product.update(fulfillable_quantity: fulfillable_quantity)
  end
end