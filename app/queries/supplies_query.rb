class SuppliesQuery < BaseQuery

  def self.list(page = 1, per_page = 12, search = '', supplies, global_settting)
    if search.present?
      paginate = api_paginate(supplies.search(search).records, page).per(per_page)
    else
      paginate = api_paginate(supplies, page).per(per_page)
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
      global_settting_enabled: global_settting,
      supplies: paginate.map{ |supply| supply}
    }
  end

end