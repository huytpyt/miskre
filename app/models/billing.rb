class Billing < ApplicationRecord
  has_many :billings_orders
  has_many :orders, through: :billings_orders
  enum status: { pending: 0, paid: 1 }
end
