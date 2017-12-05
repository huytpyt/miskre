# == Schema Information
#
# Table name: request_charges
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  total_amount :decimal(, )
#  status       :integer          default(0)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class RequestCharge < ApplicationRecord
  belongs_to :user
  has_many :orders

  enum status: %w(pending approved rejected)

  before_create do
    return if self.orders.blank?
    total_amount = self.orders.inject(0){ |sum_amount, order| sum_amount += OrderService.new.sum_money_from_order(order).to_f }
    self.total_amount = total_amount
  end
end
