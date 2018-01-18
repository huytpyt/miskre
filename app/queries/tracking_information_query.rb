class TrackingInformationQuery < BaseQuery

  class << self
    # def list(page, per_page, sort, order_by, search, current_resource)
    #   tracking_informations = TrackingInformation.all
    #   sort_options = { "#{order_by}" => sort }
    #   if tracking_informations.blank?
    #     {
    #       tracking_informations: []
    #     }
    #   else
    #     paginate = api_paginate(tracking_informations.order(sort_options).search(search), page).per(per_page)
    #     {
    #       paginator: {
    #         total_records: paginate.total_count,
    #         records_per_page: paginate.limit_value,
    #         total_pages: paginate.total_pages,
    #         current_page: paginate.current_page,
    #         next_page: paginate.next_page,
    #         prev_page: paginate.prev_page,
    #         first_page: 1,
    #         last_page: paginate.total_pages
    #       },
    #       tracking_informations: paginate.map{ |tracking_information| single(tracking_information) }
    #     }
    #   end
    # end

    def single(tracking_information, order)
      {
        id: tracking_information.id,
        fulfillment_id: tracking_information.fulfillment_id,
        tracking_number: tracking_information.tracking_number,
        status: tracking_information.status.to_s,
        order: get_order(order),
        tracking_history: eval(tracking_information.tracking_history.to_s),
        created_at: tracking_information.created_at,
        updated_at: tracking_information.updated_at
      }
    end

    def get_order order
      {
        id: order.id,
        first_name: order.first_name,
        last_name: order.last_name,
        ship_address1: order.ship_address1,
        ship_address2: order.ship_address2,
        ship_city: order.ship_city,
        ship_state: order.ship_state,
        ship_zip: order.ship_zip,
        ship_country: order.ship_country,
        ship_phone: order.ship_phone,
        shipping_method: order.shipping_method,
        shop_id: order.shop_id,
        financial_status: order.financial_status,
        order_name: order.order_name,
        tracking_number_real: order.tracking_number_real,
        line_itmes: order.line_items
      }
    end
  end
end