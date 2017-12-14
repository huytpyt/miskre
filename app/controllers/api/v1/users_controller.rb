class Api::V1::UsersController < Api::V1::BaseController
  before_action :get_user, only: [:add_balance, :request_charge_orders, :add_balance_manual]
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

  private
    def get_user
      @user = current_resource
    end
end
