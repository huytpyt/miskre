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
  end

  def self.fetch_all_shops
  end
end
