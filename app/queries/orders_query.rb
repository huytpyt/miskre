class OrdersQuery < BaseQuery

  def self.list(page = 1, per_page = 12, sort, order_by, search, key,
   shop_id, start_date, end_date, financial_status, fulfillment_status, current_resource)
    shop, orders, error = set_querry(search, shop_id, start_date, end_date, financial_status, fulfillment_status, current_resource)
    sort_options = { "#{order_by}" => sort }
    if orders.blank?
      {
        error: error,
        orders: []
      }
    else
      paginate = api_paginate(orders.order(sort_options).search(search), page).per(per_page)
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
          last_page: paginate.total_pages
        },
        orders: paginate.map{ |orders| single(orders) }
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
      remark: order.remark,
      shipping_method: order.shipping_method,
      tracking_no: order.tracking_no,
      fulfill_fee: order.fulfill_fee,
      product_name: order.product_name,
      color: order.color,
      size: order.size,
      shop_id: order.shop_id,
      created_at: order.created_at,
      updated_at: order.updated_at,
      shopify_id: order.shopify_id,
      financial_status: order.financial_status,
      fulfillment_status: order.fulfillment_status,
      paid_for_miskre: order.paid_for_miskre,
      shop_name: order.shop.name,
      order_name: order.order_name,
      total_cost: OrderService.new.sum_money_from_order(order).to_f,
      products: Product.where(sku: order.line_items.pluck(:sku)).map{|product| ProductsQuery.single(product)}
    }
  end

  def self.order_statistics shop_data
    status, errors, top_20_product, duration = shop_data
    {
      duration: duration,
      product_ranking: top_20_product.map{|product| single_ranking(product)}
    }
  end

  def self.shop_statistics shop_data
    status, errors, shop_statistics, shop, duration = shop_data
    if errors
      {
        errors: errors
      }
    else
      {
        shop_id: shop.id,
        shop_name: shop.name,
        duration: duration,
        shop_statistics: shop_statistics.map{|product| single_ranking(product)}
      }
    end
  end

  def self.single_ranking product
    {
      sku: product["sku"],
      name: LineItem.where(sku: product["sku"]).first.name,
      total_quantity: product["total_quantity"]
    }
  end

  def self.set_querry(search, shop_id, start_date, end_date, financial_status, fulfillment_status, current_resource)
    query_params = {}
    if fulfillment_status == "null"
      query_params['fulfillment_status'] = nil
    else
      query_params['fulfillment_status'] = fulfillment_status unless fulfillment_status.empty?
    end
    query_params['financial_status'] = financial_status unless financial_status.empty?
    orders_list = Order.where(date: start_date.beginning_of_day..end_date.end_of_day)

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