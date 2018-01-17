class TrackingInformationsController < ActionController::Base
  def show
    @order = Order.find params[:id]
    @fulfillment = @order.fulfillments.first
    if @fulfillment.present?
      @tracking_information = @fulfillment.tracking_information
      @tracking_information = TrackingInformationQuery.single(@tracking_information, @order)
      @products = @order.line_items.includes(product: :images).includes(product: :options).includes(product: :variants)
        .map{|item| ProductsQuery.single_for_list(item.product).merge!({ quantity: item.quantity}).merge!({item_name: item.name})}
    end
  end
end
