class UserPolicy < ApplicationPolicy
  def download_orders?
    user.staff?
  end

  def request_charge_orders?
    user.user?
  end

  def accept_charge_orders?
    user.admin?
  end
end