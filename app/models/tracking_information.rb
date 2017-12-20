# == Schema Information
#
# Table name: tracking_informations
#
#  id               :integer          not null, primary key
#  fulfillment_id   :integer
#  tracking_number  :string
#  status           :integer          default("Submited")
#  tracking_history :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  courier_name     :string
#

class TrackingInformation < ApplicationRecord
  belongs_to :fulfillment

  enum status: %w(Submited Pending Expired Exception Delivered AttemptFail OutForDelivery InTransit InfoReceived)

  class << self

    def search(search)
      if search
        where("lower(tracking_number) ILIKE :search", { search: "%#{search.downcase}%" })
      else
        scoped
      end
    end

  end
end
