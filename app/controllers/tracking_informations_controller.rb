class TrackingInformationsController < ActionController::Base
  def show
    @order = Order.find_by_shopify_id params[:id]
    token = params[:token]
    if @order && @order.fulfillments.present?
      @success = true
      @fulfillment = @order.fulfillments.first
      if @fulfillment.present?
        @tracking_information = @fulfillment.tracking_informations
        if @tracking_information.none?
          time_fulfilled = @fulfillment&.created_at
          miskre_noti = { "tag" => "Submitted", "message" => "Electronic Notification Received", "location" => "Merchant", "checkpoint_time" => (time_fulfilled - 9.minutes).to_s}
          miskre_submit = { "tag" => "Submitted", "message" => "Order Submitted", "location" => "Merchant", "checkpoint_time" => (time_fulfilled + 2.days + 15.minutes).to_s}
          miskre_process = { "tag" => "Submitted", "message" => "Order Processed", "location" => "Merchant", "checkpoint_time" => (time_fulfilled + 3.days).to_s}
          miskre_ship = { "tag" => "Submitted", "message" => "Order Shipped", "location" => "Merchant", "checkpoint_time" => (time_fulfilled + 5.days + 11.minutes).to_s}
          tracking_history = [miskre_noti, miskre_submit, miskre_process, miskre_ship]
          tracking = TrackingInformation.find_or_initialize_by(
                        fulfillment_id: @fulfillment.id,
                        tracking_number: @fulfillment.tracking_number
                      )
          tracking.tracking_history = tracking_history
          tracking.save!
        end
        if @order.tracking_number_real.present?
          unless @order.tracking_number_real == "none"
            TrackingInformationService.fetch_tracking_information @tracking_information.first
            # TrackingInformationService.delay.fetch_additional_tracking_information @tracking_information.first
          end
        end
        @tracking_information.reload
        @tracking_information = @tracking_information.map{|info| TrackingInformationQuery.single(info, @order) }
        @products = @order.line_items.map{|item| {image: ProductService.find_image(item.sku), quantity: item.quantity, item_name: item.name}}
        @orders_history = Order.where(email: @order.email).where.not(id: @order.id) if token && @order.is_order_owner?(token)
      end
    else
      @success = false
    end
  end
end
