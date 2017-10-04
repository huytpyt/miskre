class FulfillmentService
  def update_line_items order
    fulfillable_quantity_line_items = ShopifyAPI::Fulfillment.find(:first, params: {order_id: order.shopify_id}).line_items.collect {|item| [item.id, item.fulfillable_quantity]}
    array_ids = []
    array_quantity = []
    fulfillable_quantity_line_items.each {|array| array_ids.push(array[0])}
    fulfillable_quantity_line_items.each {|array| array_quantity.push(array[1])}

    quantity_index = 0
    order.line_items.where(line_item_id: array_ids).each do |line_item|
      LineItem.find(line_item.id).update(fulfillable_quantity: array_quantity[quantity_index])
      quantity_index += 1
    end
    order.line_items.where.not(line_item_id: array_ids).each do |line_item|
      LineItem.find(line_item.id).update(fulfillable_quantity: 0)
    end
  end

  def calculator_quantity quantity_array, order
    quantity_index = 0
    order.line_items.select(:sku).each do |line_item|
      if line_item.sku.length == 3
        product = Product.find_by_sku line_item.sku
        unless product.nil?
          current_quantity = product&.quantity || 0
          product.quantity = current_quantity - quantity_array[quantity_index].to_i
          ProductService.new.tracking_product_quantity(product.quantity, product)
          product.save
        end
      else
        product = Product.find_by_sku line_item.sku.first 3
        unless product.nil?
          current_quantity = product&.quantity || 0
          product.quantity = current_quantity - quantity_array[quantity_index].to_i
          ProductService.new.tracking_product_quantity(product.quantity, product)
          product.save
          variant = Variant.find_by_sku line_item.sku
          current_variant = variant.quantity || 0
          variant.quantity = current_variant - quantity_array[quantity_index].to_i
          variant.save
        end
      end
      quantity_index += 1
    end
  end
end