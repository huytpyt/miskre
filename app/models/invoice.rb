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
#  balance      :decimal(, )
#  memo         :string
#  success      :boolean          default(FALSE)
#

class Invoice < ApplicationRecord
  audited

  belongs_to :user
  has_many :orders

  enum invoice_type: %w(deposit deposit_fee transaction_fee product_cost transfer order_pay refund)
end
