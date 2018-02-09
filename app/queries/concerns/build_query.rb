module BuildQuery
  extend ActiveSupport::Concern

  def build_single_query model, record, has_association
    json_data = model.new.attributes
    data = json_data.each do |key, value|
             json_data["#{key}"] = record.send(key)
           end
    if has_association
      has_association.each do |association|
        data.merge!({"#{association}": record.send(association).map{|object| build_single_query(association.singularize.camelize.constantize, object, nil)}})
      end
    end
    data
  end

  def build_list_query model, page, per_page, sort, order_by, search, has_association
    sort_options = { "#{order_by}" => sort }
    has_association.each do |association|
      @relation = model.includes(association.to_sym)
    end
    paginate = api_paginate(@relation.search(search).order(sort_options), page).per(per_page)
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
      "#{model.to_s.pluralize.underscore}": paginate.map{ |object| build_single_query(model, object, has_association) }
    }
  end

 end