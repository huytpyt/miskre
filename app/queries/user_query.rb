class UserQuery < BaseQuery

  def self.add_balance params, user
    response_result, amount, user, errors, current_balance = UserService.add_new_balance(params, user)
    {
      status: response_result,
      amount: amount,
      id: user.id,
      email: user.email,
      errors: errors,
      current_balance: current_balance
    }
  end

end