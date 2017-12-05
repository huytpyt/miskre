class Api::V1::RequestChargesController < Api::V1::BaseController

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = RequestCharge.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:search] || ""
    key = params[:key] || nil
    render json: RequestChargesQuery.list(page, per_page, sort,
      order_by, search, key, current_resource), status: 200
  end

  def show
    request_charge = RequestCharge.find(params[:id])
    render json: RequestChargesQuery.single(request_charge), status: 200
  end
end
