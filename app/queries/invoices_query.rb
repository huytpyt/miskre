class InvoicesQuery < BaseQuery
  def self.list(invoices, page, per_page, sort, order_by)
    sort_options = { "#{order_by}" => sort }
    paginate = api_paginate(invoices.order(sort_options), page).per(per_page)
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
	  invoices: paginate.map{ |invoice| single(invoice) }
	}
  end

  def self.single invoice
    {
      id: invoice.id,
      money_amount: invoice.money_amount,
      balance: invoice.balance,
      memo: invoice.memo,
      created_at: invoice.created_at
    }
  end
end