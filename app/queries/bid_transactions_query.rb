class BidTransactionsQuery < BaseQuery
	def self.single transaction
		{
			id: transaction.id,
			cost: transaction.cost,
			time: transaction.time,
			status: transaction.status,
			product_need_auction: ProductNeed.find_by_id(transaction.product_need_id)
		}
	end

	def self.list transaction_list, page = 1, per_page = 12, search = ''
		if search.present?
			paginate = api_paginate(transaction_list.where(status: search), page).per(per_page)
		else
			paginate = api_paginate(transaction_list, page).per(per_page)
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
		  bid_transactions: paginate.map {|transaction| single(transaction)}
		}
	end
end