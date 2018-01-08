class FulfillmentService
  def update_line_items order
    order.line_items.each do |line_item|
      line_item.update(fulfillable_quantity: 0)
    end
  end

  def self.retry_fulfill fulfillment, shop_id
    begin
      shop = Shop.find(shop_id)
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      new_fulfilllment = ShopifyAPI::Fulfillment.new(order_id: fulfillment.shopify_order_id, tracking_number: fulfillment.tracking_number, tracking_url: fulfillment.tracking_url, tracking_company: fulfillment.tracking_company)
      if new_fulfilllment.save
        fulfillment.update(fulfillment_id: new_fulfilllment.id)
        fulfillment.order.update(fulfillment_status: "fulfilled")
        "Success!"
      else
        "Already fulfilled"
      end
    rescue
      "This shop already removed!"
    end
  end

  def calculate_inventory_after_fulfill orders_list
    orders_list.each do |order|
      data = order.line_items.map{|o| {quantity: o.quantity, product_id: o.product_id}}
      update_inventory_quantity(data)
    end
  end

  def update_inventory_quantity data_list
    data_list.each do |data|
      product = Product.find data[:product_id]
      inventory = product.inventory
      inventory.quantity -= data.quantity
      inventory.save
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