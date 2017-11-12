# == Schema Information
#
# Table name: fulfillments
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  fulfillment_id   :string
#  status           :string
#  service          :string
#  tracking_company :string
#  shipment_status  :string
#  tracking_number  :string
#  tracking_url     :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  items            :string
#  shopify_order_id :string
#
# Indexes
#
#  index_fulfillments_on_order_id  (order_id)
#

class Fulfillment < ApplicationRecord
  belongs_to :order
  serialize :items
end
