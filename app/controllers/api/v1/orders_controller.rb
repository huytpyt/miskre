class Api::V1::OrdersController < Api::V1::BaseController
  
  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Product.where(shop_owner: false, is_bundle: false).count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:search] || ""
    key = params[:key] || nil
    start_date = params[:start_date]&.to_date || Date.current - 7
    end_date = params[:end_date]&.to_date || Date.current
    financial_status = params[:financial_status].to_s
    fulfillment_status = params[:fulfillment_status].to_s
    shop_id = params[:shop_id] || nil
    render json: OrdersQuery.list(page, per_page, sort, order_by, search, key,
      shop_id, start_date, end_date, financial_status, fulfillment_status, current_resource), status: 200
  end

  def show
    order = Order.find(params[:id])
    render json: OrdersQuery.single(order), status: 200
  end

  def pay_for_miskre
    order_list_id = JSON.parse(params["order_list"]).split(",")
    user_id = current_resource.id
    reponse = OrderService.new.pay_for_miskre(order_list_id, user_id)
    render json: OrdersQuery.pay_for_miskre(reponse), status: 200
  end

  private
    def order_params
      params.require(:order).permit(:id)
    end
end
