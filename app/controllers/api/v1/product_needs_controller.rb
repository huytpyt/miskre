class Api::V1::ProductNeedsController < Api::V1::BaseController

  def create
    render json: ProductNeedService.create(product_need_params), status: 200
  end

  def update
    render json: ProductNeedService.update(params[:id], product_need_params), status: 200
  end

  def show
    data = ProductNeedService.show(params[:id])
    if data[:result] == "Success"
      render json: ProductNeedQuery.single(data[:product_need]), status: 200
    else
      render json: data, status: 200
    end
  end

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = ProductNeed.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q] || ""

    render json: ProductNeedQuery.list(page, per_page, sort, order_by, search), status: 200
  end

  def toggle_status
    response = ProductNeedService.toggle_status(params[:id])
    render json: response, status: 200
  end

  private

  def product_need_params
    params.permit(:product_id, :variant_id, :quantity, :status, :id)
  end

end