class UserPolicy < ApplicationPolicy
  def download_orders?
    user.staff?
  end

  def request_charge_orders?
    user.user?
  end

  def charge_product_cost?
    user.admin?
  end

  def add_shipping_fee?
    user.staff?
  end

  def charge_shipping_fee?
    user.admin?
  end
end