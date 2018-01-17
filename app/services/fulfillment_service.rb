class FulfillmentService

  # New system no need fulfill_for_order
  def fulfill_for_order order
    tracking_number = generate_tracking_number(order.country_code)
    while Fulfillment.exists?(tracking_number: tracking_number)
      tracking_number = generate_tracking_number(order.country_code)
    end
    tracking_url = TRACKING_URL + "?orderNo=" + order.shopify_id

    new_fulfilllment = ShopifyAPI::Fulfillment.new(order_id: order.shopify_id, 
      tracking_number: tracking_number, 
      tracking_url: tracking_url, 
      tracking_company: TRACKING_COMPANY
    )
    if new_fulfilllment.save
      order.fulfillments.create(
        shopify_order_id: order.shopify_id, 
        fulfillment_id: new_fulfilllment.id, 
        status: "success", 
        service: "manual", 
        tracking_company: TRACKING_COMPANY, 
        tracking_number: tracking_number,
        tracking_url: tracking_url, 
        items: order.line_items.collect {|order| {name: order.name, quantity: order.quantity}}
      )
      order.update(fulfillment_status: "fulfilled", tracking_number_real: "none")
    end
  end

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

  private 

  def generate_tracking_number country
    "MK" + rand(100000000..999999999).to_s + country
  end
end