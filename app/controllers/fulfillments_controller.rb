class FulfillmentsController < ApplicationController
  before_action :set_order
  def new
  end

  def create
    ShopifyCommunicator.new(@order.shop.id)
    items_name_array = []
    items_id_array = []
    @order.line_items.each do |line_item|
      items_name_array.push({name: line_item.name, quantity: line_item.fulfillable_quantity})
      items_id_array.push({id: line_item.line_item_id, quantity: line_item.fulfillable_quantity})
    end
    fulfillment = ShopifyAPI::Fulfillment.new(order_id: @order.shopify_id, tracking_number: params[:tracking_number], tracking_url: params[:tracking_url], line_items: items_id_array, tracking_company: params[:shipping_carrier])
    if fulfillment.save
      @order.fulfillments.create(fulfillment_id: fulfillment.id, status: fulfillment.status, service: fulfillment.service, tracking_company: fulfillment.tracking_company, shipment_status: fulfillment.shipment_status, tracking_number: fulfillment.tracking_number, tracking_url: fulfillment.tracking_url, items: items_name_array)
      @order.update(fulfillment_status: "fulfilled")
      fulfillment_service.update_line_items @order
      flash[:notice] = "Created succesfully"
      redirect_to order_path(@order)
    else
      flash[:error] = "Created failed"
      redirect_to order_path(@order)
    end
  end

  def set_order
    @order = Order.find_by_id params[:order_id]
  end

  private

  def fulfillment_service
    @fulfillment_service ||= FulfillmentService.new
  end
end
