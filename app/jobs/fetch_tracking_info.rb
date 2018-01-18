require 'sidekiq-scheduler'
class FetchTrackingInfo
  include Sidekiq::Worker

  def perform
    TrackingInformation.all.each do |tracking|
      tracking_real = tracking&.fulfillment&.order&.tracking_number_real
      if tracking_real.present?
      	unless tracking_real == "none"
      	  p "start fetch"
  	      TrackingInformationService.fetch_tracking_information(tracking)
      	end
      end
    end
  end
end