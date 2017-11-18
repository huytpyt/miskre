class ProductsQuery < BaseQuery

	def self.list(page = DEFAULT_PAGE, per_page = LIMIT_RECORDS, order = 'DESC', search = '')
		sort_options = { id: order }
		if search.present?
			paginate = api_paginate(Product.order(sort_options).search(search).records, page).per(per_page)
		else
			paginate = api_paginate(Product.order(sort_options), page).per(per_page)
		end
		{
			status: true,
			paginator: {
				total_records: paginate.total_count,
				records_per_page: paginate.limit_value,
				total_pages: paginate.total_pages,
				current_page: paginate.current_page,
				next_page: paginate.next_page,
				prev_page: paginate.prev_page,
				first_page: 1,
				last_page: paginate.total_pages
			},
			products: paginate.map{ |product| single(product) }
		}
	end

	def self.single(product)
		{
			id: product.id,
			name: product.name,
			weight: product.weight,
			length: product.length,
			height: product.height,
			width: product.width,
			sku: product.sku,
			desc: product.desc,
			price: product.price,
			compare_at_price: product.compare_at_price,
			shopify_id: product.shopify_id,
			cost: product.cost,
			link: product.link,
			epub: product.epub,
			dhl: product.dhl,
			vendor: product.vendor,
			bundle_id: product.bundle_id,
			is_bundle: product.is_bundle,
			quantity: product.quantity,
			product_ids: product.product_ids,
			user_id: product.user_id,
			product_url: product.product_url,
			fulfillable_quantity: product.fulfillable_quantity,
			cus_cost: product.cus_cost,
			cus_epub: product.cus_epub,
			cus_dhl: product.cus_dhl,
			suggest_price: product.suggest_price,
			sale_off: product.sale_off,
			shop_owner: product.shop_owner,
			shop_id: product.shop_id,
			created_at: product.created_at,
			updated_at: product.updated_at,
			options: options_for(product),
			variants: variants_for(product),
			images: images_for(product)
		}
	end

	def self.variants_for(product)
		product.variants.map do |variant|
			{
				id: variant.id,
				option1: variant.option1,
				option2: variant.option2,
				option3: variant.option3,
				quantity: variant.quantity,
				price: variant.price,
				sku: variant.sku,
				compare_at_price: variant.compare_at_price,
				product_ids: variant.product_ids
			}
		end
	end

	def self.options_for(product)
		product.options.map do |option|
			{
				id: option.id,
				name: option.name,
				values: option.values
			}
		end
	end

	def self.images_for(product)
		product.images.map do |image|
			{
				id: image.id,
				url: image.file_url
			}
		end
	end

end