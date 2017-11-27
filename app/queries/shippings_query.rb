class ShippingsQuery < BaseQuery

  def self.list(nations, page = 1, per_page = 12, sort = 'DESC', order_by = 'id', search = '')
    sort_options = { "#{order_by}" => sort }

    if search.present?
      paginate = api_paginate(nations.order(sort_options).search(search), page).per(per_page)
    else
      paginate = api_paginate(nations.order(sort_options), page).per(per_page)
    end
    {
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
      nations: paginate.map{ |nation| {nation: single(nation)}}
    }
  end

  def self.single(nation)
    {
      id: nation.id,
      code: nation.code,
      name: nation.name
    }
  end

end