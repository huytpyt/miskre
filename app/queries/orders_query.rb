class OrdersQuery < BaseQuery

  def self.list(page = 1, per_page = 12, sort, order_by, search, key,
   shop_id, start_date, end_date, financial_status, fulfillment_status, current_resource, option)
    shop, orders, error = set_querry(search, shop_id, start_date, end_date, financial_status, fulfillment_status, current_resource, option)
    sort_options = { "#{order_by}" => sort }
    if orders.blank?
      {
        error: error,
        orders: []
      }
    else
      paginate = api_paginate(orders.includes(shop: :user).order(sort_options).search(search), page).per(per_page)
      {
        error: error,
        paginator: {
          total_records: paginate.total_count,
          records_per_page: paginate.limit_value,
          total_pages: paginate.total_pages,
          current_page: paginate.current_page,
          next_page: paginate.next_page,
          prev_page: paginate.prev_page,
          first_page: 1,
          last_page: paginate.total_pages,
          option: option
        },
        orders: paginate.map{ |order| single(order) }
      }
    end
  end

  def self.accept_charge_orders reponse_result
    result, total_paid, error = reponse_result
    {
      result: result,
      total_paid_sucess: total_paid,
      errors: error
    }
  end

  def self.reject_charge_orders reponse_result
    reponse_result
  end

  def self.single(order)
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
      email: order.email,
      quantity: order.quantity,
      skus: order.skus,
      unit_price: order.unit_price,
      date: order.date,
      shipping_method: order.shipping_method,
      tracking_no: order.tracking_no,
      fulfill_fee: order.fulfill_fee,
      product_name: order.product_name,
      shop_id: order.shop_id,
      created_at: order.created_at,
      updated_at: order.updated_at,
      shopify_id: order.shopify_id,
      financial_status: order.financial_status,
      fulfillment_status: order.fulfillment_status,
      paid_for_miskre: order.paid_for_miskre,
      shop_name: order.shop.name,
      order_name: order.order_name,
      product_info: OrdersQuery.product_info_by_order(order),
      total_cost: OrderService.new.sum_money_from_order(order, false).to_f,
      products: Product.where(sku: order.line_items.pluck(:sku)).map{|product| ProductsQuery.single(product)},
      stock_warning: order.stock_warning
    }
  end

  def self.product_info_by_order order
    product_info = []
    order_raw_sql = "SELECT products.sku AS sku, SUM(line_items.quantity) AS total_quantity
                    FROM
                    (orders JOIN line_items ON orders.id = line_items.order_id
                    JOIN products ON products.id = line_items.product_id)
                    WHERE orders.id = #{order.id}
                    GROUP BY products.sku"
    result = Order.find_by_sql(order_raw_sql)
    result.each do |data|
      json = {
              product_sku: data.sku,
              quantity: data.total_quantity
            }
      product_info << json
    end
    product_info
  end

  def self.order_statistics shop_data
    status, errors, top_20_product, duration = shop_data
    {
      duration: duration,
      product_ranking: top_20_product.map{|product| single_ranking(product)}
    }
  end

  def self.shop_statistics shop_data
    status, errors, shop_statistics, total_revenue, total_profit, shop, duration = shop_data
    if errors
      {
        errors: errors
      }
    else
      {
        shop_id: shop.id,
        shop_name: shop.name,
        duration: duration,
        total_orders: Order.where("shop_id = :shop_id AND created_at > :duration", { duration: duration.days.ago.end_of_day, shop_id: shop.id }).count,
        total_revenue: total_revenue,
        total_profit: total_profit,
        shop_statistics: shop_statistics.map{|product| single_ranking(product)}
      }
    end
  end

  def self.single_ranking product
    product_info = Product.find_by_sku product["sku"]
    {
      id: product_info.id,
      sku: product["sku"],
      name: product_info.name,
      total_quantity: product["total_quantity"],
      image: images_for(product_info)
    }
  end

  def self.images_for(product)
    image = product.images.first
    {
      id: image.id,
      original: image.file.url,
      thumb: image.file.url(:thumb),
      medium: image.file.url(:medium)
    }
  end

  def self.set_querry(search, shop_id, start_date, end_date, financial_status, fulfillment_status, current_resource, option)
    query_params = {}
    if fulfillment_status == "null"
      query_params['fulfillment_status'] = nil
    else
      query_params['fulfillment_status'] = fulfillment_status unless fulfillment_status.empty?
    end
    query_params['financial_status'] = financial_status unless financial_status.empty?

    if option && current_resource.staff?
      if option == "available_fulfill_orders"
        orders_list_to_check = Order.where(date: start_date.beginning_of_day..end_date.end_of_day).charged_product

        available_orders, unvailable_orders, pickup_info = OrderService.check_order_available(orders_list_to_check)
        orders_list = available_orders
      elsif option == "unavailable_fulfill_orders"
        orders_list_to_check = Order.where(date: start_date.beginning_of_day..end_date.end_of_day).charged_product

        available_orders, unvailable_orders, pickup_info = OrderService.check_order_available(orders_list_to_check)
        orders_list = unvailable_orders
      else
        orders_list = Order.joins(:request_charge)
          .where(orders: { date: start_date.beginning_of_day..end_date.end_of_day }, request_charges: { status: RequestCharge::statuses[option.to_s]})
      end
    else
      orders_list = Order.where(date: start_date.beginning_of_day..end_date.end_of_day )
    end

    order_status = case current_resource.role
                  when "user"
                    [Order::paid_for_miskres["none_paid"],
                     Order::paid_for_miskres["requesting"],
                     Order::paid_for_miskres["charged_product"],
                     Order::paid_for_miskres["accepted"]]
                  when "admin"
                    [Order::paid_for_miskres["none_paid"],
                     Order::paid_for_miskres["requesting"],
                     Order::paid_for_miskres["charged_product"],
                     Order::paid_for_miskres["pending"],
                     Order::paid_for_miskres["accepted"]]
                  when "manager"
                    [Order::paid_for_miskres["charged_product"]]
                  end

    orders_list = orders_list.where(paid_for_miskre: order_status)

    @errors = nil
    if current_resource.staff?
      begin
        if shop_id
          @current_shop = shop_id
          @orders = orders_list.where(shop_id: shop_id).where(query_params)
        else
          @current_shop = "all"
          @orders = orders_list.where(query_params)
        end
      rescue ActiveRecord::RecordNotFound
        @current_shop = nil
        @orders = []
      end
    else
      unless current_resource.shops.empty?
        if shop_id
          @current_shop = current_resource.shops.where(id: shop_id).first.try(:id)
          if @current_shop.present?
            @orders = orders_list.where(shop_id: @current_shop).where(query_params)
          else
            @orders = []
            @errors = "Can not view shop does not belong to you"
          end
        else
          @current_shop = current_resource.shops.pluck(:id)
          @orders = orders_list.where(shop_id: @current_shop).where(query_params)
        end
      else
        @current_shop = nil
        @orders = []
      end
    end
    return [@current_shop, @orders, @errors]
  end



end