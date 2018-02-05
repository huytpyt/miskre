class FulfillmentService
  # New system no need fulfill_for_order
  def self.fulfill_for_order(order, shop)
    begin
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      tracking_number = generate_tracking_number(order&.country_code || "HK")
      while Fulfillment.exists?(tracking_number: tracking_number)
        tracking_number = generate_tracking_number(order&.country_code || "HK")
      end
      uniq_token = Customer.find_by_email(order.email)
      tracking_url = Settings.tracking_url + "orderNo=" + order.shopify_id
      tracking_url += ("?token=" + order.encode_token) if uniq_token
      new_fulfilllment = ShopifyAPI::Fulfillment.new(order_id: order.shopify_id, tracking_number: tracking_number, tracking_url: tracking_url, tracking_company: TRACKING_COMPANY)
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
        order.update(fulfillment_status: "fulfilled")
      end
      calculate_inventory_after_fulfill(order)
      p "Fulilled success"
    rescue
      order.update(fulfillment_status: "error")
      p "Something went wrong!"
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

  def self.calculate_inventory_after_fulfill order
    pickup_info = eval(order.pickup_info)
    update_inventory_quantity(pickup_info)
  end

  def self.update_inventory_quantity pickup_info
    pickup_info.each do |line|
      object = InventoryVariant.where(id: line[:variant_id]).first || Inventory.where(id: line[:inventory_id]).first
      object.quantity -= line[:quantity].to_i
      object.save
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

  def self.generate_tracking_number country
    "MK" + rand(100000000..999999999).to_s + country
  end

  def update_fulfillment order, fulfillment, get_params
    begin
      ShopifyCommunicator.new(order.shop.id)
      fulfillment.update(get_params)
      shopify_fulfillment = ShopifyAPI::Fulfillment.first(params: {order_id: fulfillment.shopify_order_id, id: fulfillment.fulfillment_id})
      shopify_fulfillment.tracking_number = get_params[:tracking_number]
      shopify_fulfillment.tracking_numbers = [get_params[:tracking_number]]
      shopify_fulfillment.tracking_url = get_params[:tracking_url]
      shopify_fulfillment.tracking_urls = [get_params[:tracking_url]]
      shopify_fulfillment.tracking_company = get_params[:tracking_company]
      shopify_fulfillment.save
      return "Update succesfully"
    rescue Exception => e
      return e.message
    end
  end
end