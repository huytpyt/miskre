class ProductService
  def self.sync_images product, supply
    product.images.each do |image|
      supply_image = supply.images.new
      supply_image.file_remote_url = Settings.original_url + image.file.url
      supply_image.save
      sleep 0.5
    end
    product.variants.each do |variant|
      variant_image = variant.images&.first
      supply_variant = supply.supply_variants.new(option1: variant.option1, option2: variant.option2, option3: variant.option3, price: variant.price, sku: variant.sku, compare_at_price: variant.compare_at_price)
      if supply_variant.save
        if variant_image
          supply_variant_image = supply_variant.images.new
          supply_variant_image.file_remote_url = Settings.original_url + variant_image.file.url
          supply_variant_image.save
          sleep 0.5
        end
      end
    end
  end

  def self.assign(shop, shopify_product, product, supply)
    shopify_product.title = product.name
    shopify_product.vendor = shop.shopify_domain
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
    if success == true
      supply.update(shopify_product_id: shopify_product.id)
      unless product.variants.empty?
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
  end

  def self.variant_name product_name, variant
    "#{product_name}#{variant.option1.present? ? ' - ' + variant.option1 : ''}#{variant.option2.present? ? ' - ' + variant.option2 : ''}#{variant.option3.present? ? ' - ' + variant.option3 : ''}"
  end

  def self.get_product_list shop
    product_ids = shop.supplies.collect {|supply| supply.product.id if (supply.product.is_bundle == false) }
    product_ids = product_ids.compact
    product_list = Product.where(id: product_ids).select(:id, :name, :suggest_price)
    ProductListsQuery.list product_list
  end

  def self.create_bundle product, shop, params
    ActiveRecord::Base.transaction do
      product_ids = []
      if params[:product][:product_ids].present?
        product_ids = params[:product][:product_ids]
      end
      product.is_bundle = true
      product.product_ids = product_ids
      product.shop_id = shop.id
      product.shop_owner = true

      total_weight = 0
      total_cost = 0
      total_price = 0
      staff_cost = 0
      product.product_ids.each do |id|
        depend_product = Product.find(id[:product_id])
        weight = depend_product.weight
        length = depend_product.length
        height = depend_product.height
        width = depend_product.width

        cal_weight = (length * height * width) / 5
        weight = cal_weight > weight ? cal_weight : weight
        total_weight += weight
        total_price += depend_product.supplies.find_by_shop_id(shop).price
        total_cost += depend_product.cus_cost
        staff_cost += depend_product.cost
      end

      product.weight = total_weight
      product.cost = staff_cost
      product.cus_cost = total_cost
      sale_off = params[:sale_off].present? ? params[:sale_off].to_i : 0
      product.suggest_price = (total_price * (100 - sale_off))/100
      if product.save
        if params[:product][:images].present?
          if params[:product][:images].is_a?(Array)
            exists_ids = []
            params[:product][:images].each do |image|
              if Image.exists?(image[:id])
                exists_ids.push(image[:id])
              end
            end
            product.image_ids = exists_ids
            product.save
          else
            {status: false, error: "`images` must an array"}
          end
        end
        if params[:product][:options].present?
          if params[:product][:options].is_a?(Array)
            params[:product][:options].each do |option|
              if option[:name].present?
                opt = product.options.new(name: option[:name], values: option[:values])
                opt.save!
              end
            end
            product.regen_variants
          else
            {status: false, error: "`options` must an array"}
          end
        end
        ProductsQuery.bundle_single(product)
      else
        {status: false, error: product.errors.full_messages}
      end
    end
  end

  def self.update_bundle product, shop, params
    product_ids = []
    if params[:product][:product_ids].present?
      product_ids = params[:product][:product_ids]
      if product.product_ids != product_ids
        product.product_ids = product_ids
        total_weight = 0
        total_cost = 0
        total_price = 0
        product.product_ids.each do |id|
          depend_product = Product.find(id[:product_id])
          weight = depend_product.weight
          length = depend_product.length
          height = depend_product.height
          width = depend_product.width
          cal_weight = (length * height * width) / 5
          weight = cal_weight > weight ? cal_weight : weight
          total_weight += weight
          total_cost += depend_product.cus_cost
          staff_cost += depend_product.cost
          total_price += depend_product.supplies.find_by_shop_id(shop).price
        end
        product.weight = total_weight
        product.cost = staff_cost
        product.cus_cost = total_cost
        product.suggest_price = ((total_price * (100 - bundle_params[:sale_off].to_i))/100).round(2)

        random = rand(2.25 .. 2.75)
        product.variants.each do |variant|
          variant.product_ids = product_ids
          variant.price = product.suggest_price
          variant.compare_at_price = (variant.price * random/ 5).round(0) * 5
          variant.save
        end
      end
    else
      return {status: false, error: "Products depend can't none"}
    end
    if product.save
      if params[:product][:images].present?
        if params[:product][:images].is_a?(Array)
          exists_ids = []
          params[:product][:images].each do |image|
            if Image.exists?(image[:id])
              exists_ids.push(image[:id])
            end
          end
          product.image_ids = exists_ids
          product.save
        else
          {status: false, error: "`images` must an array"}
        end
      end
      if params[:product][:options].present?
        if params[:product][:options].is_a?(Array)
          opts = []
          params[:product][:options].each do |option|
            option_id = option[:id]
            if option_id
              opt = Option.find(option_id)
              if opt
                opt.name = option[:name] if option[:name].present?
                opt.values = option[:values] if option[:values].present?
                opt.save if opt.changed?
              end
            else
              opt = product.options.create!(name: option[:name], values: option[:values])
            end
            opts << opt.id
          end
          product.options.where.not(id: opts).destroy_all
        else
          {status: false, error: "`options` must an array"}
        end

        if params[:product][:variants].present?
          if params[:product][:variants].is_a?(Array)
            vts = []
            params[:product][:variants].each do |variant|
              variant_id = variant[:id]
              product_ids = variant[:product_ids]

              if variant_id
                vt = Variant.find(variant_id)
                if vt
                  vt.product_ids = product_ids
                  if variant[:image].present?
                    exists_ids = Image.exists?(variant[:image][:id]) ? [variant[:image][:id]] : []
                    vt.image_ids = exists_ids
                  end
                  VariantService.update_variant product, vt
                  vt.save
                  vts << vt.id
                end
              end
            end
            product.variants.where.not(id: vts).destroy_all
          else
            {status: false, error: "`variants` must an array"}
          end
        end
      else
        product.options.destroy_all
        product.variants.destroy_all
      end
      ProductsQuery.bundle_single(product)
    else
      {status: false, error: product.errors.full_messages}
    end
  end

  def update_fulfillable_quantity_descrease items_array_sku
    items_array_sku.each do |item|
      update_fulfillable_quantity_each_item item[:sku], item[:quantity]
    end
  end

  def update_fulfillable_quantity_each_item sku, quantity
    product = Product.find_by_sku(sku&.first(3))
    if product.present?
      fulfillable_quantity = (product&.fulfillable_quantity || 0) - quantity.to_i
      product.update_column(:fulfillable_quantity, fulfillable_quantity)
    end
  end

  def update_fulfilable_quantity_increase sku, quantity
    product = Product.find_by_sku(sku&.first(3))
    if product.present?
      fulfillable_quantity = (product&.fulfillable_quantity || 0) + quantity.to_i
      product.update_column(:fulfillable_quantity, fulfillable_quantity)
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