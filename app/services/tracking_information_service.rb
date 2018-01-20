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
          tracking_information.tracking_history = [
            { "tag" => "Submitted", "message" => "Electronic Notification Received , Order Processed", "location" => "Merchant", "checkpoint_time" => (Time.now - 9.minutes).to_s},
            { "tag" => "Submitted", "message" => "Order Submitted", "location" => "Merchant", "checkpoint_time" => (Time.now + 5.days + 15.minutes).to_s},
            { "tag" => "Submitted", "message" => "Order Processed", "location" => "Merchant", "checkpoint_time" => (self.order.created_at + 7.days).to_s},
            { "tag" => "Submitted", "message" => "Order Shipped", "location" => "Merchant", "checkpoint_time" => (Time.now + 8.days + 11.minutes).to_s}
          ]
          tracking_information.Submited!
        elsif tracking_checkpoint["data"].present?
          miskre_noti = eval(tracking_information.tracking_history)[0]
          miskre_submit = eval(tracking_information.tracking_history)[1]
          miskre_process = eval(tracking_information.tracking_history)[2]
          miskre_ship = eval(tracking_information.tracking_history)[3]
          last_status = tracking_checkpoint["data"]["tracking"]["checkpoints"].last.try(:[], "tag")
          tracking_information.tracking_history = tracking_checkpoint["data"]["tracking"]["checkpoints"].unshift(miskre_ship).unshift(miskre_process).unshift(miskre_submit).unshift(miskre_noti)
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
      ship_to_country_code = order.country_code
      ship_to_country = order.ship_country
      iso3_country_code = IsoCountryCodes.find(ship_to_country_code)&.alpha3 || IsoCountryCodes.search_by_name(ship_to_country)&.first&.alpha3

      courier_list = COURIER.select{|key, value| key.include?(iso3_country_code)}.values.flatten
      courier_list.each do |courier|
        AfterShip::V4::Tracking.create(tracking_label, {name: tracking_label, slug: courier[:courier], destination_country_iso3: iso3_country_code})
        temp_info = AfterShip::V4::Tracking.get(courier[:courier], tracking_label)
        if temp_info.try(:[], "data").try(:[], "tracking").try(:[], "checkpoints").present?
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
                                      tracking_number: fulfillment.tracking_number,
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