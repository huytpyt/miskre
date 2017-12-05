class VariantsQuery < BaseQuery

	def self.list(product)
		product.variants.map{ |variant| single(variant) }
	end

	def self.list_supply supply_variants
		supply_variants.map{ |supply_variant| single_supply(supply_variant) }
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
			image: image_for(variant),
			created_at: variant.created_at,
			updated_at: variant.updated_at
		}
	end

	def self.single_supply(supply_variant)
		{
			id: supply_variant.id,
			option1: supply_variant.option1,
			option2: supply_variant.option2,
			option3: supply_variant.option3,
			price: supply_variant.price,
			sku: supply_variant.sku,
			supply_id: supply_variant.supply_id,
			compare_at_price: supply_variant.compare_at_price,
			product_ids: supply_variant&.variant&.product_ids,
			image: image_for(supply_variant),
			created_at: supply_variant.created_at,
			updated_at: supply_variant.updated_at
		}
	end

	private

	def self.image_for(variant)
		image = variant.images&.first
		if image
			{
				id: image.id,
				original: image.file.url,
	  			thumb: image.file.url(:thumb),
	  			medium: image.file.url(:medium),
	  			created_at: image.created_at,
	  			updated_at: image.updated_at
			}
		end
	end

end

