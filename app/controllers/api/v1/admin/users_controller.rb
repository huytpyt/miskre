class Api::V1::Admin::UsersController < Api::V1::BaseController
  before_action :get_user, only: [:create, :update, :destroy, :show, :index]

  def show
    render json: {
      id: @user.id,
      email: @user.email,
      name: @user.name,
      role: @user.role,
      customer_id: @user.customer_id,
      is_paid: @user.is_paid,
      period_end: @user.period_end,
      parent_id: @user.parent_id,
      reference_code: @user.reference_code,
      enable_ref: @user.enable_ref,
      fb_link: @user.fb_link
    }, status: 200
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
    render json: UserQuery.list(page, per_page, sort, order_by, search), status: 200
  end

  def create
    result, errors, user = UserService.create(user_params)
    render json: { result: result, errors: errors, user: user }, status: 200
  end

  def update
    result, errors, user = UserService.update(params[:id], user_params)
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
      params.permit(:name, :fb_link, :password, :password_confirmation, :role, :enable_ref, :id, :email)
    end
end