class UserProductsController < ApplicationController
	before_action :prepare_user_product, only: [:show, :approve]

	def show
	end

	def approve
		if @product.approve!
			if assgin_product(@product)
				redirect_to request_products_path, notice: 'Successfully!'
			end
		end
	end

	private

		def prepare_user_product
			@product = UserProduct.find(params[:id])
		end

		def assgin_product(product)
			ActiveRecord::Base.transaction do
				name = product.name
				sku = product.sku
				price = product.price
				shopify_product_id= product.shopify_product_id
				shop_id = product.shop_id
				user_id = product.user_id
				weight = product.weight
				desc = product.desc
				quantity = product.quantity
				compare_at_price = product.compare_at_price

				assign_product = Product.new(name: name, weight: weight, sku: sku, desc: desc, cost: price, quantity: quantity, suggest_price: (price.to_f * 1.5), compare_at_price: compare_at_price, user_id: user_id)
				if assign_product.save!
					supply = create_suppy(assign_product, shop_id, user_id, shopify_product_id)
					product.user_variants.each do |v|
						option1 = v.option1
  					option2 = v.option2
  					option3 = v.option3
  					quantity = v.quantity
  					price = v.price
  					sku = v.sku
  					compare_at_price = v.compare_at_price
  					Variant.create!(option1: option1, option2: option2, option3: option3, quantity: quantity, price: price, sku: sku, user_id: user_id, compare_at_price: compare_at_price, product_id: assign_product.id)
					end

					product.images.each do |img|
						image = assign_product.images.new
				    image.file_remote_url= "#{request.base_url}/#{img.file_url}"
				    image.save!
					end
				end
			end
		end

		def create_suppy(product, shop_id, user_id, shopify_product_id)
			supply = Supply.new(
				product_id: product.id, 
				shop_id: shop_id, 
				shopify_product_id: shopify_product_id,
				price: product.price,
				compare_at_price: product.compare_at_price)
			supply.copy_product_attr_add_product
      if supply.save
        product.variants.each do |variant|
          supply.supply_variants.create(option1: variant.option1, option2: variant.option2, option3: variant.option3, price: variant.price, sku: variant.sku, compare_at_price: variant.compare_at_price)
        end
      end
		end
end