require 'sidekiq-scheduler'
class FetchTrackingInfo
  include Sidekiq::Worker

  def perform
    TrackingInformation.pluck(:id).each do |id|
      sleep(3)
      TrackingInformationService.fetch_tracking_information(id)
    end
  end
end