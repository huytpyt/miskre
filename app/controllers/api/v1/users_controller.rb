class Api::V1::UsersController < Api::V1::BaseController
  before_action :get_user, only: [:add_balance, :request_charge_orders, :add_balance_manual, :create, :update, :destroy, :index]

  def index
    user = current_resource
    render json: UserQuery.single(user), status: 200
  end

  def add_balance
    if @user.user?
      response_result = UserQuery.add_balance(params, @user)
      render json: response_result, status: 200
    else
      render json: { result: "Permission denied" }, status: 200
    end
  end

  def add_balance_manual
    if @user.admin?
      response_result = UserQuery.add_balance_manual(params, @user)
      render json: response_result, status: 200
    else
      render json: { result: "Permission denied" }, status: 200
    end
  end

  def request_charge_orders
    order_list_id = params[:order_list_id]
    response_result = UserQuery.request_charge_orders(order_list_id, @user)
    render json: response_result, status: 200
  end

  def update
    result, errors, user = UserService.update(params[:id], user_params)
    render json: { result: result, errors: errors, user: user }, status: 200
  end

  private
    def get_user
      @user = current_resource
    end

    def user_params
       params.permit(:name, :fb_link, :password, :password_confirmation, :id, :email)
    end
end
