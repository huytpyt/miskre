class BalanceService
  def self.get_balance user
    if user.balance.present?
      [user.id, user.balance.total_amount.to_f, user.email]
    else
      [user.id, "No balance", user.email]
    end
  end
end