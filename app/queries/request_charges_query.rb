class RequestChargesQuery < BaseQuery

  def self.list(page = DEFAULT_PAGE, per_page = LIMIT_RECORDS, sort = 'DESC', order_by = 'id', search = '', key = nil, current_resource)
    sort_options = { "#{order_by}" => sort }
    paginate = api_paginate(RequestCharge.search(search).order(sort_options), page).per(per_page)
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
      requests: paginate.map{ |request| single(request) }
    }
  end

  def self.single(request)
    {
      id: request.id,
      user_id: request.user_id,
      user_email: request.user.email,
      total_amount: request.total_amount.to_f,
      status: request.status.to_s,
      created_at: request.created_at,
      updated_at: request.updated_at,
      orders: request.orders.map{ |order| OrdersQuery.single(order)}
    }
  end
end