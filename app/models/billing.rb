class Billing < ApplicationRecord
  has_many :billings_orders, dependent: :destroy
  has_many :orders, through: :billings_orders
  enum status: { pending: 0, paid: 1, processing: 2, refunded: 3}
end
