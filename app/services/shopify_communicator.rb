class ShopifyCommunicator
  def initialize(shop_id)
    @shop = Shop.find(shop_id)
    @session = ShopifyAPI::Session.new(@shop.shopify_domain, @shop.shopify_token)
    ShopifyAPI::Base.activate_session(@session)
  end

  def get_order_params(o)
    quantity = 0
    skus = []
    unit_prices = []
    shipping_methods = []
    products = []

    o.line_items.each do |item|
      quantity += item.quantity
      skus.append("#{item.sku} * #{item.quantity}")
      unit_prices.append(item.price)
      products.append(item.title)
    end

    o.shipping_lines.each do |s|
      shipping_methods.append(s.title)
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

  def sync_orders(start_date=10.day.ago, end_date=DateTime.now)
    params = {
      status: 'any',
      created_at_min: start_date.strftime("%FT%T%:z"),
      created_at_max: end_date.strftime("%FT%T%:z")
    }

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
          begin
            order_params = get_order_params(o)
            new_order = @shop.orders.new(order_params)
            if new_order.save
              add_line_items(new_order, o.line_items)
            end
          rescue NoMethodError => e
            p 'invalid order'
          end
        end

        sleep 0.5
      #rescue
      #  p "Error Connection. Try again ..."
      #  next 
      end
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
        total_discount: li.total_discount
      }
      order.line_items.create(li_params)
    end
  end

  def add_product(product_id)
    product = Product.find(product_id)

    new_product = ShopifyAPI::Product.new
    assign(new_product, product)

    Supply.create(shop_id: @shop.id, product_id: product.id, shopify_product_id: new_product.id)
  end

  def sync_product(product_id)
    product = Product.find(product_id)
    supplies = Supply.where(product_id: product.id, shop_id: @shop.id)
    supplies.each do |s|
      shopify_product = ShopifyAPI::Product.find(s.shopify_product_id)
      assign(shopify_product, product)
    end
  end

  def assign(shopify_product, product)
    shopify_product.title = product.name
    shopify_product.vendor = product.vendor
    shopify_product.body_html = product.desc
    shopify_product.images = product.images.collect do |i|
      # p URI.join(request.url, i.file.url(:original)).to_s
      # { "src" => URI.join(request.url, i.file.url(:original)) }
      raw_content = Paperclip.io_adapters.for(i.file).read
      encoded_content = Base64.encode64(raw_content)
      { "attachment" => encoded_content }
    end

    variants = []
    unless product.variants.empty?
      variants = product.variants.collect do |v|
        {
          'option1': v.option1,
          'option2': v.option2,
          'option3': v.option3,
          'weight': product.weight,
          'weight_unit': 'g',
          'price': v.price,
          'sku': v.sku
        }
      end
    else
      variants = [{
        'weight': product.weight,
        'weight_unit': 'g',
        'price': product.price
      }]
    end
    shopify_product.variants = variants
    response = shopify_product.save

    if response && !product.variants.empty?
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

          img = ShopifyAPI::Image.new(product_id: shopify_product.id, image: image_params)
          img.save
        end
      end
    end
  end

  def remove_product(product_id)
    ShopifyAPI::Base.activate_session(@session)
    supply = Supply.find_by(shop_id: @shop.id, product_id: product_id)
    if supply
      begin
        ShopifyAPI::Product.delete(supply.shopify_product_id)
      rescue ActiveResource::ResourceNotFound
      end
      supply.destroy
    end
  end
end
