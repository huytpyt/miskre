class Api::V1::OrdersController < Api::V1::BaseController

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Order.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q] || ""
    key = params[:key] || nil
    start_date = params[:start_date]&.to_date || Date.current - 7
    end_date = params[:end_date]&.to_date || Date.current
    financial_status = params[:financial_status].to_s
    fulfillment_status = params[:fulfillment_status].to_s
    shop_id = params[:shop_id] || nil
    option = params[:option] || nil
    render json: OrdersQuery.list(page, per_page, sort, order_by, search, key,
      shop_id, start_date, end_date, financial_status, fulfillment_status, current_resource, option), status: 200
  end

  def show
    order = Order.find(params[:id])
    render json: OrdersQuery.single(order), status: 200
  end

  def find_shopify_order
    shopify_id = params[:shopify_id]
    order = Order.find_by_shopify_id shopify_id
    if order
      render json: OrdersQuery.single(order), status: 200
    else
      render json: { errors: "Can not find order with shopify_id: #{shopify_id}"}, status: 200
    end
  end

  def fulfill_order
    order_id = params[:order_id]
    tracking_number = params[:tracking_number]
    result, errors = OrderService.new.create_fulfillment_for_order(order_id, tracking_number)
    render json: { result: result, errors: errors }, status: 200
  end

  def accept_charge_orders
    authorize current_user
    order_list_id = params["order_list_id"]
    reponse = OrderService.new.accept_charge_orders(order_list_id)
    render json: OrdersQuery.accept_charge_orders(reponse), status: 200
  end

  def reject_charge_orders
    if current_user.staff?
      request_charge_id = params["request_charge_id"]
      reponse = OrderService.new.reject_charge_orders(request_charge_id)
      render json: OrdersQuery.reject_charge_orders(reponse), status: 200
    else
      render json: { errors: "Permission denied" }, status: 401
    end
  end

  def order_statistics
    duration = params[:duration].to_i
    response = OrderService.new.order_statistics(duration)
    render json: OrdersQuery.order_statistics(response), status: 200
  end

  def shop_statistics
    shop_id = params[:shop_id].to_i
    duration = params[:duration].to_i
    response = OrderService.new.shop_statistics(shop_id, current_user, duration)
    render json: OrdersQuery.shop_statistics(response), status: 200
  end

  def download_orders
    authorize current_user
    response = OrderService.download_orders(params[:order_list_id])
    render json: { result: "OK", file_path: response}, status: 200
  end

  private
    def order_params
      params.require(:order).permit(:id)
    end
end
