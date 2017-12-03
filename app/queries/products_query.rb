class ProductsQuery < BaseQuery

	def self.list(page = DEFAULT_PAGE, per_page = LIMIT_RECORDS, sort = 'DESC', order_by = 'id', search = '', key = nil, current_resource)
		sort_options = { "#{order_by}" => sort }

		products = Product.where(shop_owner: false, is_bundle: false)
		if key.present? && Product.column_names.include?(key)
			products = products.where("#{key}": [nil, false] )
		end
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
			products: paginate.map{ |product| current_resource.partner? ? single_partner(product) : single(product) }
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
			products: paginate.map{ |product| single_for_list(product) }
		}
	end

	def self.single_partner(product) 
		{
			id: product.id,
			name: product.name,
			weight: product.weight,
			length: product.length,
			height: product.height,
			width: product.width,
			sku: product.sku,
			desc: product.desc,
			vendor_detail: product.vendor_detail,
			cost_per_quantity: product.cost_per_quantity,
			approved: product.approved,
			created_at: product.created_at,
			updated_at: product.updated_at,
			options: options_for(product),
			variants: variants_for(product),
			images: images_for(product),
			categories: product.categories.ids,
			resource_images: product.resource_images
		}
	end

	def self.single_for_list(product)
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
			link: product.link,
			epub: product.epub,
			bundle_id: product.bundle_id,
			is_bundle: product.is_bundle,
			product_ids: product.product_ids,
			product_url: product.product_url,
			cus_cost: product.cus_cost,
			cus_epub: product.cus_epub,
			suggest_price: product.suggest_price,
			sale_off: product.sale_off,
			resource_url: product.resource_url,
			approved: product.approved,
			created_at: product.created_at,
			updated_at: product.updated_at,
			options: options_for(product),
			variants: variants_for(product),
			images: images_for(product),
			categories: product.categories.ids
		}
	end

	def self.single(product)
		if product.cost_per_quantity.nil?
			product.cost_per_quantity = [{"quantity"=>1, "cost"=>product.cost}]
			product.save
		end
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
			approved: product.approved,
			created_at: product.created_at,
			updated_at: product.updated_at,
			options: options_for(product),
			variants: variants_for(product),
			images: images_for(product),
			categories: product.categories.ids,
			resource_images: product.resource_images
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