# == Schema Information
#
# Table name: invoices
#
#  id           :integer          not null, primary key
#  invoice_type :integer
#  user_id      :string
#  money_amount :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Invoice < ApplicationRecord
  belongs_to :user
  has_many :orders

  enum invoice_type: %w(add_balance order_pay)
end
