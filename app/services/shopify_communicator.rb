class ShopifyCommunicator
  def initialize(shop_id)
    @shop = Shop.find(shop_id)
    @session = ShopifyAPI::Session.new(@shop.shopify_domain, @shop.shopify_token)
  end

  def count_order
    shopify_params = {
      financial_status: 'paid', 
      fulfillment_status: ['partial', 'unshipped'],
      limit: 10
    }
    ShopifyAPI::Order.find(:count, params: shopify_params).count
  end

  def sample_order
    shopify_params = {
      financial_status: 'paid', 
      fulfillment_status: ['partial', 'unshipped'],
      limit: 10
    }
    ShopifyAPI::Order.find(:all, params: shopify_params)
  end

  def download_order
    shopify_params = {
      financial_status: 'paid', 
      fulfillment_status: ['partial', 'unshipped']
    }
    orders = ShopifyAPI::Order.find(:all, params: shopify_params)

    csv = CSV.generate do |csv|
      column_names =  ["OrderId", "First Name", "Last Name", 
                       "Ship Address1", "Ship Address2", "Ship City", 
                       "Ship State", "Ship Zip", "Ship Country", 
                       "Ship Phone", "Email", "Quantity", "SKUs Info", 
                       "Unit Price", "Date", "Remark", "Shipping Method", 
                       "Tracking No.", "Fulfill Fee", "Product Name", 
                       "Color", "Size"]
      csv << column_names
      orders.each do |order|
        quantity = 0
        skus = []
        unit_prices = []
        shipping_methods = []
        products = []

        order.line_items.each do |item|
          quantity += item.quantity
          skus.append("#{item.sku} * #{item.quantity}")
          unit_prices.append(item.price)
          products.append(item.title)
        end

        order.shipping_lines.each do |s|
          shipping_methods.append(s.title)
        end

        row = [order.id, order.customer.first_name, order.customer.last_name,
               order.shipping_address.address1, order.shipping_address.address2,
               order.shipping_address.city, order.shipping_address.province,
               order.shipping_address.zip, order.shipping_address.country,
               order.shipping_address.phone, order.customer.email,
               quantity, skus.join(","), unit_prices.join(","), order.created_at,
               "remark", shipping_methods.join(","), "0", "0", products.join(","),
               "Color", "Size"]

        csv << row
      end
    end
    return csv
  end

  def add_product(product_id)
    ShopifyAPI::Base.activate_session(@session)
    product = Product.find(product_id)

    new_product = ShopifyAPI::Product.new
    new_product.title = product.name
    new_product.vendor = product.vendor
    new_product.body_html = product.desc
    new_product.images = product.images.collect do |i|
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

    new_product.variants = variants
    new_product.save

    Supply.create(shop_id: @shop.id, product_id: product.id, shopify_product_id: new_product.id)
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
