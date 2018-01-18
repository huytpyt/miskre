class TrackingInformationService
  POPULAR_COURIERS_CODE = ["china-ems", "ups", "fedex", "dhl", "usps"]
  class << self
    def fetch_tracking_information tracking_information
      tracking_label = tracking_information.fulfillment.order.tracking_number_real || tracking_information.fulfillment.tracking_number

      get_courier = AfterShip::V4::Courier.detect({ tracking_number: tracking_label })
      courier = get_courier.try(:[], "data").try(:[], "couriers")&.first&.try(:[], "slug")
      if courier
        tracking_checkpoint = AfterShip::V4::Tracking.get(courier, tracking_label)
      else
        POPULAR_COURIERS_CODE.each do |courier|
          temp_info = AfterShip::V4::Tracking.get(courier, tracking_label)
          if temp_info.try(:[], "data").present?
            @info = temp_info
            break
          end
        end
        tracking_checkpoint = @info
      end
      if tracking_checkpoint.nil?
        tracking_checkpoint = {"data": {}}
      end
      if tracking_information.tracking_history.nil? && !tracking_checkpoint["data"].present?
        tracking_information.tracking_history = [{ "tag" => "Submitted", "message" => "SUBMITTED", "location" => "Merchant", "checkpoint_time" => (tracking_information.fulfillment.order.created_at - 6.minutes).to_s},
                                                 { "tag" => "Submitted", "message" => "Electronic Notification Received , Order Processed", "location" => "Merchant", "checkpoint_time" => tracking_information.fulfillment.order.created_at.to_s}]
        tracking_information.Submited!
      elsif tracking_checkpoint["data"].present?
        miskre_package = eval(tracking_information.tracking_history)[0]
        miskre_processed = eval(tracking_information.tracking_history)[1]
        last_status = tracking_checkpoint["data"]["tracking"]["checkpoints"].last.try(:[], "tag")
        tracking_information.tracking_history = tracking_checkpoint["data"]["tracking"]["checkpoints"].unshift(miskre_processed).unshift(miskre_package)
        tracking_information.courier_name = tracking_checkpoint["data"]["tracking"]["checkpoints"].last.try(:[], "slug")
        tracking_information.send("#{last_status}!") if last_status.present?
        tracking_information.save
      end
    end
  end
end