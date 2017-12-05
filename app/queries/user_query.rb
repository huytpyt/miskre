class UserQuery < BaseQuery

  def self.add_balance params, user
    response_result, amount, user, errors, current_balance = UserService.add_new_balance(params, user)
    {
      status: response_result,
      amount: amount,
      user_id: user.id,
      email: user.email,
      errors: errors,
      current_balance: current_balance
    }
  end

  def self.add_balance_manual params, user
    response_result, amount, user, errors, current_balance = UserService.add_balance_manual(params, user)
    {
      status: response_result,
      amount: amount,
      user_id: user.id,
      email: user.email,
      errors: errors,
      current_balance: current_balance
    }
  end

  def self.request_charge_orders order_list_id, user
    UserService.request_charge_orders(order_list_id, user)
  end
end