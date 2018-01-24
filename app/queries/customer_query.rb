class CustomerQuery < BaseQuery
  def self.single customer
    {
      id: customer.id,
      shopify_order_id: customer.shopify_order_id,
      email: customer.email,
      token: customer.token,
      fullname: customer.fullname,
      ship_address1: customer.ship_address1,
      ship_address2: customer.ship_address2,
      ship_city: customer.ship_city,
      ship_state: customer.ship_state,
      ship_zip: customer.ship_zip,
      ship_country: customer.ship_country,
      ship_phone: customer.ship_phone,
      shipping_method: customer.shipping_method,
      country_code: customer.country_code,
      total_quantity: customer.total_quantity,
      created_at: customer.created_at,
      updated_at: customer.updated_at,
      cus_line_items: customer.cus_line_items.map{ |item| CusLineItemQuery.single(item)}
    }
  end

  def self.list(page = DEFAULT_PAGE, per_page = LIMIT_RECORDS, sort = 'DESC', order_by = 'total_quantity', search = '')
    sort_options = { "#{order_by}" => sort }
    paginate = api_paginate(Customer.search(search).order(sort_options), page).per(per_page)
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
      customers: paginate.includes(:cus_line_items).map{ |customer| single(customer) }
    }
  end

  def self.customers_statistic(page = DEFAULT_PAGE, per_page = LIMIT_RECORDS, search = '')
    customers_statistic = CustomerService.customers_statistic
    paginate = paginate_array(customers_statistic.select{|item| item[:title].include?(search)}, page).per(per_page)
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
        data: paginate.map{|data| data }
    }
  end
end