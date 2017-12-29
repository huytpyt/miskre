class Api::V1::UsersController < Api::V1::BaseController
  before_action :get_user, only: [:add_balance, :request_charge_orders, :add_balance_manual, :create, :update, :destroy]
  def show
  	user = current_resource
    render json: {
  		id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      customer_id: user.customer_id,
      is_paid: user.is_paid,
      period_end: user.period_end,
      parent_id: user.parent_id,
      reference_code: user.reference_code,
      enable_ref: user.enable_ref,
      fb_link: user.fb_link
  	}, status: 200
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

  def create
    if @user.admin?
      result, errors, user = UserService.create(user_params)
      render json: { result: result, errors: errors, user: user }, status: 200
    else
      render json: { result: "Permission denied" }, status: 200
    end
  end

  def update
    if @user.admin?
      result, errors, user = UserService.update(params[:id], user_params)
      render json: { result: result, errors: errors, user: user }, status: 200
    else
      render json: { result: "Permission denied" }, status: 200
    end
  end

  def destroy
    if @user.admin?
      result, errors, user = UserService.destroy(params[:id])
      render json: { result: result, errors: errors, user: user }, status: 200
    else
      render json: { result: "Permission denied" }, status: 200
    end
  end

  private
    def get_user
      @user = current_resource
    end

    def user_params
       params.permit(:name, :fb_link, :password, :password_confirmation, :role, :customer_id, :reference_code, :enable_ref, :id, :email)
    end
end
