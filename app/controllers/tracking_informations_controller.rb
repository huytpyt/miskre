class TrackingInformationsController < ActionController::Base
  def show
    @order = Order.find_by_shopify_id params[:id]
    token = params[:token]
    if @order && @order.fulfillments.present?
      @success = true
      @fulfillment = @order.fulfillments.first
      if @fulfillment.present?
        @tracking_information = @fulfillment.tracking_informations
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
