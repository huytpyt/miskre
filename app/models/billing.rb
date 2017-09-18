class Billing < ApplicationRecord
  has_many :billings_orders, dependent: :destroy
  enum status: { pending: 0, paid: 1 }
end
