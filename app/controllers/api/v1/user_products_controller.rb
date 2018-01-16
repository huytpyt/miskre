class Api::V1::UserProductsController < Api::V1::BaseController
  # before_action :check_user, only: [:accept_with_matched_product, :accept_as_new_product]
  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = UserProduct.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q] || ""
    render json: UserProductQuery.list(page, per_page, sort, order_by, search), status: 200
  end

  def show
    user_product = UserProduct.find(params[:id])
    render json: UserProductQuery.single(user_product), status: 200
  end

  def accept_with_matched_product
    user_product_id = params[:user_product_id]
    matched_product_id = params[:matched_product_id]
    result, errors, user_product = UserProductService.accept_with_matched_product(user_product_id, matched_product_id)
    render json: { result: result, errors: errors, user_product: user_product}
  end

  def accept_as_new_product
    user_product_id = params[:user_product_id]
    result, errors, supply = UserProductService.accept_as_new_product(user_product_id)
    render json: { result: result, errors: errors, supply: supply}
  end

  private
  def check_user
    if current_user.staff?
      render json: {error: "Permission denied!"}, status: 500
    end
  end
end
