class TrackingInformationService
  POPULAR_COURIERS_CODE = ["china-ems", "ups", "fedex", "dhl", "usps"]
  class << self
    def fetch_tracking_information tracking_information_id
      tracking_information = TrackingInformation.find tracking_information_id
      tracking_label = tracking_information.tracking_number

      get_courier = AfterShip::V4::Courier.detect({ tracking_number: tracking_label })
      courier = get_courier.try(:[], "data").try(:[], "couriers").first.try(:[], "slug")
      tracking_checkpoint = if courier
                              AfterShip::V4::Tracking.get(courier, tracking_label)
                            else
                              POPULAR_COURIERS_CODE.each do |courier|
                                @info = AfterShip::V4::Tracking.get(courier, tracking_label).try(:[], "data")
                                break if @info.present?
                              end
                              @info
                            end

      if tracking_information.tracking_history.nil? && !tracking_checkpoint["data"].present?
        tracking_information.tracking_history = [{ status: "Submitted", message: "Packaged by Miskre"}]
        tracking_information.Submited!
      elsif tracking_checkpoint["data"].present?
        last_status = tracking_checkpoint["data"]["tracking"]["checkpoints"].last.try(:[], "tag")
        tracking_information.tracking_history = tracking_checkpoint["data"]["tracking"]["checkpoints"].unshift({ status: "Submitted", message: "Packaged by Miskre"})
        tracking_information.courier_name = courier
        tracking_information.send("#{last_status}!") if last_status.present?
        tracking_information.save
      end
    end
  end
end