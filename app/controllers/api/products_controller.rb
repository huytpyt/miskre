class Api::ProductsController < Api::ApiController
	before_action :prepare_nation, only: :profit_calculator

	def profit_calculator
		if @national
			us_shipping_type = @national.shipping_types.where(code: 'BEUS')&.first
			us_shipping_type ||= @national.shipping_types.first
			if us_shipping_type
				cost = params[:cost].to_f
				weight = params[:weight].to_f
				suggest_price = params[:suggest_price].to_f
				product_cus_epub = params[:product_cus_epub].to_f
				beus_cost = CarrierService.cal_cost(us_shipping_type, weight)
				if beus_cost
					diff_cost = beus_cost > product_cus_epub ? (beus_cost - product_cus_epub)*0.8 : 0
					beus_price = (0.2*beus_cost + diff_cost).round(2)
					total_cost = (cost + beus_cost).round(2)
					total_price = (suggest_price + beus_price).round(2)
					profit = (total_price - total_cost).round(2)
					json_response = {
						cost: cost, 
						weight: weight, 
						product_cus_epub: product_cus_epub,
						suggest_price: suggest_price,  
						beus_cost: beus_cost, 
						beus_price: beus_price,
						total_cost: total_cost, 
						total_price: total_price, 
						profit: profit
					}
					render json: {status: true, product: json_response}, status: 200
				else
					render json: {status: false, message: "Weight Not Valid!"}, status: 500
				end
			else
				render json: {status: false, message: "Shipping type unavailable!"}, status: 500
			end
		else
			render json: {status: false, message: "Nation unavailable!"}, status: 500
		end
	end

	# POST /api/product/sync_products/:shop_id
	def sync_products
		shop_id = params[:shop_id]
		if shop_id
			products = SyncProductService.fetch_by_shop(shop_id)
			if products.empty?
				render json: {status: false, message: 'Not found!'}, status: 404
			else
				user_id = Shop.find(shop_id)&.user_id
				sync_products = save_sync_products(products, user_id)
				if sync_products.empty?
					render json: {status: false, message: "Can not save sync products!"}, status: 500
				else
					render json: {status: true, products: sync_products, message: 'Successfully!'}, status: 200
				end
			end
		else
			render json: {status: false, message: "Missing shop_id parameter!"}, status: 500
		end
	end

	private

		def prepare_nation
      @national = Nation.find_by_code('US')
      @national ||= Nation.first
    end

    def save_sync_products(sync_products, user_id)
    	STDERR.puts sync_products.first.inspect 
    	sync_products.each do |pro|
    		pro_name = pro.title
    		pro_desc = pro.body_html
    		variants = pro.variants
    		unless variants.empty?
	    		variant = variants.first
	  			variant_product_id = variant.product_id
	  			variant_title = variant.title
	  			pro_name = variant_title == "Default Title" ? pro_name : "#{pro_name} - #{variant_title}"
	  			variant_price = variant.price
	  			variant_sku = variant.sku
	  			variant_grams = variant.grams
	  			variant_inventory_quantity = variant.inventory_quantity > 0 ? variant.inventory_quantity : 0
	  			variant_weight = variant.weight
	  			variant_weight_unit = variant.weight_unit
	  			variant_compare_at_price = variant.compare_at_price
	  			new_product = Product.new(name: pro_name, weight: convert_to_gram(variant_weight, variant_weight_unit), sku: variant_sku, desc: pro_desc, cost: variant_price, quantity: variant_inventory_quantity, suggest_price: (variant_price.to_f * 1.5), compare_at_price: variant_compare_at_price, user_id: user_id)
	  			new_product.save!

	    		if new_product
	    			if variants.count > 1
	    				sku_str = ""
		  				variants.each_with_index do |v, index|
		  					option1 = v.option1
		  					option2 = v.option2
		  					option3 = v.option3
		  					quantity = v.inventory_quantity > 0 ? v.inventory_quantity : 0
		  					price = v.price
		  					sku = v.sku
		  					sku_str += (index+1 == variants.count) ? sku : "#{sku}_"
		  					compare_at_price = v.compare_at_price
		  					new_variant = Variant.new(option1: option1, option2: option2, option3: option3, quantity: quantity, price: price, sku: sku, compare_at_price: compare_at_price, product_id: new_product.id)
		  					new_variant.save!
		  					new_product.update(sku: sku_str)
		  				end
		  			end

		  			#Save image
	    			img = pro.image
	    			if img && img.src
		    			image = new_product.images.new
					    image.file_remote_url= img.src
					    image.save!
					  end
	    		end
	    	end
    	end
    end

    def convert_to_gram(weight, weight_unit)
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

end
