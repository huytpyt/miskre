class ProductListsQuery < BaseQuery
	def self.list products
		products.map{|product| single(product)}
	end
	def self.single product
		{
			id: product.id,
			name: product.name,
			price: product.suggest_price,
			variants: variants_for(product)
		}
	end

	def self.variants_for(product)
		product.variants.map do |variant|
			{
				id: variant.id,
				name: ProductService.variant_name(product.name, variant)
			}
		end
	end
end