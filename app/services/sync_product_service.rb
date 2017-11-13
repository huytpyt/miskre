class SyncProductService

  def self.fetch_by_shop(shop_id)
  	begin
      @shop = Shop.find(shop_id)
      @session = ShopifyAPI::Session.new(@shop.shopify_domain, @shop.shopify_token)
      ShopifyAPI::Base.activate_session(@session)
    rescue
      p "UnauthorizedAccess"
    end
  	select_products = []
  	total_products = ShopifyAPI::Product.find(:count)&.count || 0
  	total_pages = total_products / 50 + 1
  	fetched_pages = 0
    current_page = 0
    while fetched_pages < total_pages
      current_page = fetched_pages + 1
      p "Fetching #{current_page} / #{total_pages} pages"
      begin
        fetched_pages += 1
	      params = {page: current_page}
	  		products = ShopifyAPI::Product.find(:all, params: params)
	  		products.each do |product|
	  			product_variants = product.variants
	  			select_product_variants = product_variants.select do |pv|
	  				pv unless Product.exists?(sku: pv.sku) || Variant.exists?(sku: pv.sku)
	  			end
	  			unless select_product_variants.empty?
		  			# STDERR.puts select_product_variants.inspect
		  			# STDERR.puts "\n"
		  			# STDERR.puts product.inspect
		  			select_products << product
		  		end
	  		end
	  		sleep 0.5
	  	end
    end
    select_products
    shop = Shop.find(shop_id)
    user_id = shop.user_id
    save_sync_products(select_products, user_id, shop_id)
  end

  def self.save_sync_products(sync_products, user_id, shop_id)
      sync_products.each do |pro|
         pro_name = pro.title
         pro_desc = pro.body_html
         variants = pro.variants
         unless variants.empty?
            variant = variants.first
            variant_product_id = variant.product_id
            variant_title = variant.title
            variant_price = variant.price
            variant_sku = variant.sku
            variant_grams = variant.grams
            variant_inventory_quantity = variant.inventory_quantity > 0 ? variant.inventory_quantity : 0
            variant_weight = variant.weight
            variant_weight_unit = variant.weight_unit
            variant_compare_at_price = variant.compare_at_price

            unless UserProduct.exists?(shopify_product_id: variant_product_id)
                user_product = UserProduct.new(shopify_product_id: variant_product_id,name: pro_name, weight: convert_to_gram(variant_weight, variant_weight_unit), sku: variant_sku, desc: pro_desc, price: variant_price, quantity: variant_inventory_quantity, compare_at_price: variant_compare_at_price, user_id: user_id, shop_id: shop_id)
                user_product.save
                if user_product
                  if variants.count > 1
                    sku_str = ""
                    variants.each_with_index do |v, index|
                      option1 = v.option1
                      option2 = v.option2
                      option3 = v.option3
                      quantity = v.inventory_quantity > 0 ? v.inventory_quantity : 0
                      price = v.price
                      sku = v.sku
                      sku_str += (index+1 == variants.count) ? sku : "#{sku}-"
                      compare_at_price = v.compare_at_price
                      new_variant = UserVariant.new(option1: option1, option2: option2, option3: option3, quantity: quantity, price: price, sku: sku, compare_at_price: compare_at_price, user_product_id: user_product.id)
                      new_variant.save!
                      user_product.update(sku: sku_str)
                  end
                end
                #Save image
                img = pro.image
                if img && img&.src
                  image = user_product.images.new
                  image.file_remote_url= img.src
                  image.save!
                end
            end
          end
        end
    end
  end

  def self.convert_to_gram(weight, weight_unit)
    w = case weight_unit
    when "lb"
      weight * 453.59237
    when "g"
      weight
    when "kg"
      weight * 1000
    when "oz"
      weight * 28.3495231
    end
    w = w > 4000 ? 4000 : w
    w = w < 10 ? 10 : w
  end

  def self.fetch_all_shops
  end
end
