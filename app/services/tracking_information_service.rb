class TrackingInformationService
  POPULAR_COURIERS_CODE = ["china-ems", "ups", "fedex", "dhl", "usps"]
  class << self

    def fetch_tracking_information tracking_information
      tracking_label = tracking_information&.fulfillment&.order&.tracking_number_real
      if tracking_label
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
          tracking_information.tracking_history = [{ "tag" => "Submitted", "message" => "Order Submitted", "location" => "Merchant", "checkpoint_time" => (tracking_information.fulfillment.order.created_at - 6.days).to_s},
                                                   { "tag" => "Submitted", "message" => "Electronic Notification Received , Order Processed", "location" => "Merchant", "checkpoint_time" => (tracking_information.fulfillment.order.created_at - 5.days).to_s}]
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

    def fetch_additional_tracking_information tracking_information
      fulfillment = tracking_information.fulfillment
      tracking_label = tracking_information&.fulfillment&.order&.tracking_number_real
      order = tracking_information&.fulfillment&.order
      ship_to_country = order.ship_country == "Vietnam" ? "Viet Nam" : order.ship_country
      iso3_country_code = IsoCountryCodes.search_by_name(ship_to_country).first.alpha3
      courier_list = COURIER.select{|key, value| key.include?(iso3_country_code)}.values.flatten

      courier_list.each do |courier|
        AfterShip::V4::Tracking.create(tracking_label, {slug: courier[:courier]})
        temp_info = AfterShip::V4::Tracking.get(courier[:courier], tracking_label)
        if temp_info.try(:[], "data").present?
          @info = temp_info
          @courier = courier[:courier]
          break
        else
          AfterShip::V4::Tracking.delete(courier[:courier], tracking_label)
        end
      end
      tracking_checkpoint = @info

      if tracking_checkpoint.present? && tracking_checkpoint["data"].present?
        last_status = tracking_checkpoint["data"]["tracking"]["checkpoints"].last.try(:[], "tag")
        if fulfillment.tracking_informations.where(courier_name: @courier).present?
          tracking_information = fulfillment.tracking_informations.where(courier_name: @courier).first
          tracking_information.tracking_history = tracking_checkpoint["data"]["tracking"]["checkpoints"]
          tracking_information.save
        else
          new_tracking_information = TrackingInformation.create(
                                      fulfillment_id: fulfillment.id,
                                      tracking_number: tracking_label,
                                      tracking_history: tracking_checkpoint["data"]["tracking"]["checkpoints"],
                                      courier_name: tracking_checkpoint["data"]["tracking"]["checkpoints"].last.try(:[], "slug"),
                                      )
          last_status = tracking_checkpoint["data"]["tracking"]["checkpoints"].last.try(:[], "tag")
          new_tracking_information.send("#{last_status}!") if last_status.present?
        end
      end
    end

  end
end