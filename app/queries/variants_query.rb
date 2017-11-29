class VariantsQuery < BaseQuery

	def self.list(product)
		product.variants.map{ |variant| single(variant) }
	end

	def self.single(variant)
		{
			id: variant.id,
			option1: variant.option1,
			option2: variant.option2,
			option3: variant.option3,
			quantity: variant.quantity,
			price: variant.price,
			sku: variant.sku,
			product_id: variant.product_id,
			user_id: variant.user_id,
			compare_at_price: variant.compare_at_price,
			product_ids: variant.product_ids,
			images: images_for(variant),
			created_at: variant.created_at,
			updated_at: variant.updated_at
		}
	end

	private

		def self.images_for(variant)
			image = variant.images&.first
			if image
				{
					id: image.id,
					url: image.file_url,
		  			thumb: image.file.url(:thumb),
		  			medium: image.file.url(:medium)
				}
			end
		end

end

