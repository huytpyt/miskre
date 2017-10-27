class ProductService
  def update_fulfillable_quantity_descrease items_array_sku
    items_array_sku.each do |item|
      update_fulfillable_quantity_each_item item[:sku], item[:quantity]
    end
  end

  def update_fulfillable_quantity_each_item sku, quantity
    product = Product.find_by_sku(sku&.first(3))
    if product.present?
      fulfillable_quantity = (product&.fulfillable_quantity || 0) - quantity.to_i
      product.update(fulfillable_quantity: fulfillable_quantity)
    end
  end

  def update_fulfilable_quantity_increase sku, quantity
    product = Product.find_by_sku(sku&.first(3))
    if product.present?
      fulfillable_quantity = (product&.fulfillable_quantity || 0) + quantity.to_i
      product.update(fulfillable_quantity: fulfillable_quantity)
    end
  end

  def tracking_product_quantity product_quantity, product
    today_tracking = product.tracking_products.where("created_at >= ?", Time.zone.now.beginning_of_day)
    if today_tracking.none?
      product.tracking_products.create(open: product_quantity, high: product_quantity, low: product_quantity, close: product_quantity)
    else
      today_tracking = today_tracking.first
      if product_quantity < today_tracking.low
        today_tracking.low = product_quantity
      elsif product_quantity > today_tracking.high
        today_tracking.high = product_quantity
      end
      today_tracking.close = product_quantity
      today_tracking.save
    end
  end
end