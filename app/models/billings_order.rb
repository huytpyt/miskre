# == Schema Information
#
# Table name: billings_orders
#
#  id         :integer          not null, primary key
#  billing_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  order_id   :integer
#
# Indexes
#
#  index_billings_orders_on_billing_id  (billing_id)
#  index_billings_orders_on_order_id    (order_id)
#

class BillingsOrder < ApplicationRecord
  belongs_to :billing
  belongs_to :order
end
