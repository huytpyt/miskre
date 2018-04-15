require 'sidekiq-scheduler'
class FetchTrackingInfo
  include Sidekiq::Worker

  def perform
    Fulfillment.all.each do |fulfillment|
      if fulfillment.tracking_informations.present?
        tracking_real = fulfillment&.order&.tracking_number_real
        if tracking_real.present?
          unless tracking_real == "none"
            p "start fetch"
            TrackingInformationService.fetch_tracking_information(fulfillment.tracking_informations.first)
            # TrackingInformationService.fetch_additional_tracking_information(fulfillment.tracking_informations.first)
          end
        end
      end
    end
  end
end