class Api::V1::BalancesController < Api::V1::BaseController
  def get_balance
    render json: BalanceQuery.get_balance(current_resource)
  end
end
