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
  has_many :tracking_informations, dependent: :destroy
  serialize :items

  after_commit do
    if self.order
      miskre_noti = { "tag" => "Submitted", "message" => "Electronic Notification Received", "location" => "Merchant", "checkpoint_time" => (Time.now - 9.minutes).to_s}
      miskre_submit = { "tag" => "Submitted", "message" => "Order Submitted", "location" => "Merchant", "checkpoint_time" => (Time.now + 2.days + 15.minutes).to_s}
      miskre_process = { "tag" => "Submitted", "message" => "Order Processed", "location" => "Merchant", "checkpoint_time" => (Time.now + 3.days).to_s}
      miskre_ship = { "tag" => "Submitted", "message" => "Order Shipped", "location" => "Merchant", "checkpoint_time" => (Time.now + 5.days + 11.minutes).to_s}
      tracking_history = [miskre_noti, miskre_submit, miskre_process, miskre_ship]
      tracking = TrackingInformation.find_or_initialize_by(
                    fulfillment_id: self.id,
                    tracking_number: self.tracking_number
                  )
      tracking.tracking_history = tracking_history
      tracking.save!
    end
  end
end
