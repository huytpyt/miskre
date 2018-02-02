class Api::V1::CustomersController < Api::V1::BaseController
  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Customer.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'total_quantity'
    search = params[:q] || ""
    render json: CustomerQuery.list(page, per_page, sort, order_by, search), status: 200
  end

  def show
    customer = Customer.find(params[:id])
    render json: CustomerQuery.single(customer), status: 200
  end

  def customers_statistic
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    search = params[:q] || ""
    render json: CustomerQuery.customers_statistic(page, per_page, search)
  end
end