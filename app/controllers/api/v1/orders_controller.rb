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

  def accept_charge_orders
    if current_user.staff?
      request_charge_id = params["request_charge_id"]
      reponse = OrderService.new.accept_charge_orders(request_charge_id)
      render json: OrdersQuery.accept_charge_orders(reponse), status: 200
    else
      render json: { errors: "Permission denied" }, status: 401
    end
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

  private
    def order_params
      params.require(:order).permit(:id)
    end
end
