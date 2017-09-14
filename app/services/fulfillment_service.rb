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
end