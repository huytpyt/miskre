class ShippingsQuery < BaseQuery

  def self.list(nations, page = 1, per_page = 12, sort = 'DESC', order_by = 'id', search = '', shipping_setting)
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
      nations: paginate.map{ |nation| {nations: single(nation, shipping_setting)}}
    }
  end

  def self.single(nation, shipping_setting)
    if shipping_setting
      {
          user_nation: nation,
          shipping_lines: show_shipping_types(nation.user_shipping_types)
      }
    else
      {
        id: nation.id,
        code: nation.code,
        name: nation.name
      }
    end
  end

  def self.show_shipping_types user_shipping_types
    shipping_type = []
    user_shipping_types.each do |user_shipping_type|
      type = user_shipping_type&.shipping_type
      if type.present?
        detail = type.has_handling ? type.detail_shipping_types : type.detail_no_handlings
        min_weight = detail.minimum(:weight_from)
        max_weight = detail.maximum(:weight_to)
        min_item = detail.where(weight_from: min_weight).first
        max_item = detail.where(weight_to: max_weight).last
         if type.has_handling
          if detail.first&.handling_fee.present?
            cost_compare = {min: {min_cost: min_item&.cost, handling_fee: min_item&.handling_fee + 0.5}, max: {max_cost: max_item&.cost, handling_fee: max_item&.handling_fee + 0.5}}
          end
        else
          if detail.first&.cost.present?
            cost_compare = {min: {min_cost: min_item&.cost + 0.5}, max: {max_cost: max_item&.cost + 0.5}}
          end
        end
        shipping_type.push({user_shipping_type: user_shipping_type, id: type.id, code: type.code, time_range: type.time_range, has_handling: type.has_handling, weight: {min_weight: min_item&.weight_from, max_weight: max_item&.weight_to}, cost_compare: cost_compare})
      end
    end
    shipping_type
  end

end