class ProductsQuery < BaseQuery

	def self.list(page = DEFAULT_PAGE, per_page = LIMIT_RECORDS, sort = 'DESC', order_by = 'id', search = '', key = nil)
		sort_options = { "#{order_by}" => sort }

		product = Product.where(shop_owner: false)
		if key.present? && Product.column_names.include?(key)
			product = product.where("#{key} = ''")
		end
		if search.present?
			paginate = api_paginate(product.order(sort_options).search(search), page).per(per_page)
		else
			paginate = api_paginate(product.order(sort_options), page).per(per_page)
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

	def self.list_miskre(products, page = DEFAULT_PAGE, per_page = LIMIT_RECORDS, sort = 'DESC', order_by = 'id', search = '')
		sort_options = { "#{order_by}" => sort }
		if search.present?
			paginate = api_paginate(products.order(sort_options).search(search), page).per(per_page)
		else
			paginate = api_paginate(products.order(sort_options), page).per(per_page)
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

	def self.single_partner(product) 
		{

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
			suggest_price: product.suggest_price,
			sale_off: product.sale_off,
			shop_owner: product.shop_owner,
			shop_id: product.shop_id,
			resource_url: product.resource_url,
			vendor_detail: product.vendor_detail,
			cost_per_quantity: product.cost_per_quantity,
			created_at: product.created_at,
			updated_at: product.updated_at,
			options: options_for(product),
			variants: variants_for(product),
			images: images_for(product)
		}
	end

	def self.variants_for(product)
		product.variants.map do |variant|
			VariantsQuery.single(variant)
		end
	end

	def self.options_for(product)
		product.options.map do |option|
			{
				id: option.id,
				name: option.name,
				values: option.values,
				created_at: option.created_at,
				updated_at: option.updated_at
			}
		end
	end

	def self.images_for(product)
		product.images.map do |image|
			{
				id: image.id,
				url: image.file_url,
	  		thumb: image.file.url(:thumb),
	  		medium: image.file.url(:medium),
	  		created_at: image.created_at,
				updated_at: image.updated_at
			}
		end
	end

end