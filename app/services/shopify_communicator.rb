class ShopifyCommunicator
  def initialize(shop_id)
    begin
      @shop = Shop.find(shop_id)
      @session = ShopifyAPI::Session.new(@shop.shopify_domain, @shop.shopify_token)
      ShopifyAPI::Base.activate_session(@session)
    rescue
      p "UnauthorizedAccess"
    end
  end

  def get_order_params(o, line_items)
    quantity = 0
    skus = []
    unit_prices = []
    shipping_methods = []
    products = []
    line_items.each do |item|
      quantity += item.quantity
      skus.append("#{item.sku} * #{item.quantity}")
      unit_prices.append(item.price)
      products.append(item.title)
    end

    o.shipping_lines.each do |s|
      shipping_methods.append(s.code)
    end

    {
      shopify_id: o.id,
      first_name: o.customer.first_name,
      last_name: o.customer.last_name,
      ship_address1: o.shipping_address.address1,
      ship_address2: o.shipping_address.address2,
      ship_city: o.shipping_address.city,
      ship_state: o.shipping_address.province,
      ship_zip: o.shipping_address.zip,
      ship_country: o.shipping_address.country,
      ship_phone: o.shipping_address.phone,
      email: o.customer.email,
      financial_status: o.financial_status,
      fulfillment_status: o.fulfillment_status,
      quantity: quantity,
      skus: skus.join(","),
      unit_price: unit_prices.join(","),
      date: o.created_at,
      remark: "",
      shipping_method: shipping_methods.join(","),
      product_name: products.join(",")
    }
  end

  def sync_fulfillments(billing_id)
    order_ids = @shop.orders.ids
    fulfillments = Fulfillment.where(fulfillment_id: nil, order_id: order_ids)
    count = fulfillments.size
    total_pages = count / 50 + 1
    fetched_pages = 0
    current_page = 0
    count_fulfilled = 0
    while fetched_pages < total_pages
      current_page = fetched_pages + 1
      p "Fetching #{current_page} / #{total_pages} pages"
      begin
        fetched_pages += 1
        fulfillments.each do |fulfillment|
          begin
            if fulfillment.present?
              new_fulfilllment = ShopifyAPI::Fulfillment.new(order_id: fulfillment.shopify_order_id, tracking_number: fulfillment.tracking_number, tracking_url: fulfillment.tracking_url, tracking_company: fulfillment.tracking_company)
              if new_fulfilllment.save
                quantity_array = fulfillment.items.collect{ |item| item[:quantity]}
                FulfillmentService.new.calculator_quantity quantity_array, fulfillment.order
                fulfillment.update(fulfillment_id: new_fulfilllment.id)
                count_fulfilled += 1
              end
            end
          rescue NoMethodError => e
            p 'invalid fulfillment'
          end
        end
        sleep 0.5
      end
    end
    if count_fulfilled == count
      Billing.find_by_id(billing_id).update(status: "pending")
    end
  end

  def sync_orders(start_date=10.day.ago, end_date=DateTime.now)
    params = {
      status: 'any',
      created_at_min: start_date.strftime("%FT%T%:z"),
      created_at_max: end_date.strftime("%FT%T%:z")
    }
    begin
      count = ShopifyAPI::Order.find(:count, params: params).count
      total_pages = count / 50 + 1
      fetched_pages = 0
      current_page = 0

      while fetched_pages < total_pages
        current_page = fetched_pages + 1
        p "Fetching #{current_page} / #{total_pages} pages"
        begin
          params["page"] = current_page
          orders = ShopifyAPI::Order.find(:all, params: params )
          fetched_pages += 1

          orders.each do |o|
            select_items = o.line_items.select do |o_item|
              o_item if Product.exists?(sku: o_item.sku.first(3))
            end
            unless select_items.empty?
              begin
                order_params = get_order_params(o, select_items)
                new_order = @shop.orders.new(order_params)
                if new_order.save
                  add_line_items(new_order, select_items)
                end
              rescue NoMethodError => e
                p 'invalid order'
              end
            end
          end
          sleep 0.5
        end
      end
    rescue
      p "error on this shop"
    end
  end

  def add_line_items(order, line_items)
    line_items.each do |li|
      li_params = {
        # product_id: li.product_id,
        quantity: li.quantity,
        sku: li.sku,
        variant_id: li.variant_id,
        variant_title: li.variant_title,
        grams: li.grams,
        title: li.title,
        name: li.name,
        price: li.price,
        total_discount: li.total_discount,
        fulfillable_quantity: li.fulfillable_quantity,
        fulfillment_status: li.fulfillment_status,
        line_item_id: li.id
      }
      order.line_items.create(li_params)
      ProductService.new.update_fulfilable_quantity_increase li.sku, li.fulfillable_quantity
      SupplyService.new.update_fulfilable_quantity_increase li.sku, li.fulfillable_quantity, order.shop_id
    end
  end

  def add_product(product_id)
    product = Product.find(product_id)

    new_product = ShopifyAPI::Product.new
    assign(new_product, product)

    if @shop.present?
      supply = Supply.new(shop_id: @shop.id,
                    product_id: product.id,
                    user_id: @shop.user_id,
                    shopify_product_id: new_product.id)
      supply.copy_product_attr_add_product
      if supply.save
        product.images.each do  |image| 
          supply_image = supply.images.new(file: ORIGINAL_URL+ image.file.url)
          supply_image.save
        end
        product.variants.each do |variant|
          variant_image = variant.images&.first
          supply_variant = supply.supply_variants.new(option1: variant.option1, option2: variant.option2, option3: variant.option3, price: variant.price, sku: variant.sku, compare_at_price: variant.compare_at_price)
          if supply_variant.save
            if variant_image
              supply_variant_image = supply_variant.images.new(file: ORIGINAL_URL + variant_image.file.url)
              supply_variant_image.save
            end
          end
        end
      end
    end
  end

  def sync_product(supply_id)
    supply = Supply.find(supply_id)
    shopify_product = ShopifyAPI::Product.find(supply.shopify_product_id)
    assign(shopify_product, supply.product, supply)
  end

  def sync_supply(supply_id)
    supply = Supply.find(supply_id)
    product = supply.product
    supply_variants = supply.supply_variants

    shopify_product = ShopifyAPI::Product.find(supply.shopify_product_id)
    shopify_product.title = supply.name
    shopify_product.vendor = @shop.shopify_domain
    shopify_product.body_html = supply.desc
    shopify_product.images = supply.images.collect do |i|
      { "src" => URI.join(Rails.application.secrets.default_host, i.file.url(:original)).to_s }
      raw_content = Paperclip.io_adapters.for(i.file).read
      encoded_content = Base64.encode64(raw_content)
      { "attachment" => encoded_content }
    end

    unless supply_variants.empty?
      # shopify_product.options = product.options.collect do |o|
      #   { "name" => o.name.capitalize }
      # end
      variants = supply_variants.collect do |v|
        {
          'option1': v.option1,
          'option2': v.option2,
          'option3': v.option3,
          'weight': product.weight,
          'weight_unit': 'g',
          'compare_at_price': v.compare_at_price,
          'price': v.price,
          'sku': v.sku
        }
      end
    else
      variants = [{
        'weight': product.weight,
        'weight_unit': 'g',
        'price': supply.price,
        'compare_at_price': supply.compare_at_price,
        'sku': product.sku
      }]
    end
    shopify_product.variants = variants
    success = shopify_product.save
    if success == true && !supply_variants.empty?
      supply_variants.each do |v|
        unless v.images.empty?
          shopify_v = shopify_product.variants.find {|sv| sv.sku == v.sku}

          img = v.images.first
          raw_content = Paperclip.io_adapters.for(img.file).read
          encoded_content = Base64.encode64(raw_content)

          image_params = {
            "variant_ids" => [shopify_v.id],
            "attachment" => encoded_content,
            "filename" => img.file_file_name
          }
          shopify_img = ShopifyAPI::Image.new(product_id: shopify_product.id, image: image_params)
          shopify_img.save
        end
      end
    end
  end

  def assign(shopify_product, product, supply=nil)
    shopify_product.title = product.name
    shopify_product.vendor = @shop.shopify_domain
    shopify_product.body_html = product.desc
    shopify_product.images = product.images.collect do |i|
      { "src" => URI.join(Rails.application.secrets.default_host, i.file.url(:original)).to_s }
      raw_content = Paperclip.io_adapters.for(i.file).read
      encoded_content = Base64.encode64(raw_content)
      { "attachment" => encoded_content }
    end

    variants = []
    unless product.variants.empty?
      shopify_product.options = product.options.collect do |o|
        { "name" => o.name.capitalize }
      end
      variants = product.variants.collect do |v|
        {
          'option1': v.option1,
          'option2': v.option2,
          'option3': v.option3,
          'weight': product.weight,
          'weight_unit': 'g',
          'compare_at_price': v.compare_at_price,
          'price': v.price,
          'sku': v.sku
        }
      end
    else
      variants = [{
        'weight': product.weight,
        'weight_unit': 'g',
        'price': product.suggest_price,
        'compare_at_price': product.compare_at_price,
        'sku': product.sku
      }]
    end
    shopify_product.variants = variants
    success = shopify_product.save
    if success == true && !product.variants.empty?
      product.variants.each do |v|
        unless v.images.empty?
          shopify_v = shopify_product.variants.find {|sv| sv.sku == v.sku}

          img = v.images.first
          raw_content = Paperclip.io_adapters.for(img.file).read
          encoded_content = Base64.encode64(raw_content)

          image_params = {
            "variant_ids" => [shopify_v.id],
            "attachment" => encoded_content,
            "filename" => img.file_file_name
          }
          shopify_img = ShopifyAPI::Image.new(product_id: shopify_product.id, image: image_params)
          shopify_img.save
        end
      end
    end
  end

  def remove_product(product_id)
    ShopifyAPI::Product.delete(product_id)
  rescue ActiveResource::ResourceNotFound
  end
end
