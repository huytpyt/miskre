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
  has_one :tracking_information, dependent: :destroy
  serialize :items

  after_commit do
    miskre_package = { "tag" => "Submitted", "message" => "SUBMITTED", "location" => "Merchant", "checkpoint_time" => (Time.zone.now - 6.minutes).to_s}
    miskre_processed = { "tag" => "Submitted", "message" => "Electronic Notification Received , Order Processed", "location" => "Merchant", "checkpoint_time" => Time.zone.now.to_s}
    tracking_history = [miskre_package, miskre_processed]
    tracking = TrackingInformation.find_or_initialize_by(
                  fulfillment_id: self.id,
                  tracking_number: self.tracking_number
                )
    tracking.tracking_history = tracking_history
    if self.tracking_number.present? && tracking.new_record?
      AfterShip::V4::Tracking.create(self.tracking_number, {name: self.tracking_number})
    end
    tracking.save!
  end
end
