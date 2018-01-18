class TrackingInformationsController < ActionController::Base
  def show
    @order = Order.find_by_shopify_id params[:id]
    if @order
      @success = true
      @fulfillment = @order.fulfillments.first
      if @fulfillment.present?
        @tracking_information = @fulfillment.tracking_information
        if @order.tracking_number_real.present?
          unless @order.tracking_number_real == "none"
            TrackingInformationService.delay.fetch_tracking_information @tracking_information
          end
        end
        @tracking_information.reload
        @tracking_information = TrackingInformationQuery.single(@tracking_information, @order)
        @products = @order.line_items.map{|item| {image: find_image(item.sku), quantity: item.quantity, item_name: item.name}}
      end
    else
      @success = false
    end
  end

  private

  def find_image sku
    if sku.length == 3
      image = Product.find_by_sku(sku)&.images&.first
    elsif sku.length == 6
      image = Variant.find_by_sku(sku)&.images&.first
    end
    image
  end
end
