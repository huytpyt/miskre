# == Schema Information
#
# Table name: billings
#
#  id         :integer          not null, primary key
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Billing < ApplicationRecord
  has_many :billings_orders, dependent: :destroy
  has_many :orders, through: :billings_orders
  enum status: { pending: 0, paid: 1, processing: 2, refunded: 3}
end
