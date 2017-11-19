class ImagesQuery < BaseQuery

	def self.list(page = DEFAULT_PAGE, per_page = LIMIT_RECORDS, sort = 'DESC', order_by= 'id')
		sort_options = { "#{order_by}" => sort }
		paginate = api_paginate(Image.order(sort_options), page).per(per_page)
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
			images: paginate.map{ |image| single(image) }
		}
	end

	def self.single(image)
		{
			id: image.id,
  		image: image.file_url,
  		thumb: image.file.url(:thumb),
  		medium: image.file.url(:medium),
  		created_at: image.created_at
		}
	end

	
end