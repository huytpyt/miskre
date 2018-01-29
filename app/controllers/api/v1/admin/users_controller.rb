class Api::V1::Admin::UsersController < Api::V1::BaseController
  before_action :get_user, only: [:create, :update, :destroy, :show, :index]

  def show
    user = User.find(params[:id])
    render json: UserQuery.single(user), status: 200
  end

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = User.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q] || ""
    type = params[:user_type] || nil
    render json: UserQuery.list(page, per_page, type, sort, order_by, search), status: 200
  end

  def create
    result, errors, user = UserService.create(user_params, supplier_params)
    render json: { result: result, errors: errors, user: user }, status: 200
  end

  def update
    result, errors, user = UserService.update(params[:id], user_params, supplier_params)
    render json: { result: result, errors: errors, user: user }, status: 200
  end

  def destroy
    result, errors, user = UserService.destroy(params[:id])
    render json: { result: result, errors: errors, user: user }, status: 200
  end

  def user_relations
    user = User.find params[:user_id]
    relations = UserQuery.user_relations(user)
    render json: relations, status: 200
  end

  private
    def get_user
      @user = current_resource
      unless @user.admin?
        render json: { result: "Permission denied" }, status: 200
      end
    end

    def user_params
      params.permit(:name, :fb_link, :password, :password_confirmation, :role, :enable_ref, :id, :email, :active, :phone, :birthday, :active)
    end

    def supplier_params
       params.permit(:company_name, :address, :activate)
    end
end