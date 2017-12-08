class BalanceQuery < BaseQuery
  def self.get_balance user
    id, total_amount, email = BalanceService.get_balance(user)
    {
      user_id: id,
      balance: total_amount,
      email: email
    }
  end
end