class ShopifyCommunicator
  def initialize(shop_id)
    @shop = Shop.find(shop_id)
    @session = ShopifyAPI::Session.new(@shop.shopify_domain, @shop.shopify_token)
  end

  def add_product(product_id)
    ShopifyAPI::Base.activate_session(@session)
    product = Product.find(product_id)

    new_product = ShopifyAPI::Product.new
    new_product.title = product.name
    new_product.vendor = "Miskre"
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
