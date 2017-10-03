class FulfillmentsController < ApplicationController
  before_action :set_order
  def new
  end

  def create
    ShopifyCommunicator.new(@order.shop.id)
    line_item_id_array = []
    items_name_array = []
    line_item_sku_array = []
    @order.line_items.each do |line_item|
      fulfillable_quantity = line_item&.fulfillable_quantity.present? ? line_item&.fulfillable_quantity : 0
      if fulfillable_quantity > 0 
        line_item_id_array.push(line_item.line_item_id)
        items_name_array.push(line_item.name)
        line_item_sku_array.push(line_item.sku)
      end
    end
    quantity_array = params[:quantity]
    array_size = line_item_id_array.size
    line_item_array = []
    items_array = []
    items_array_sku = []
    array_size.times do |index|
      line_item_array.push({id: line_item_id_array[index].to_i, quantity: quantity_array[index].to_i})
      items_array.push({name: items_name_array[index], quantity: quantity_array[index].to_i})
      items_array_sku.push({sku: line_item_sku_array[index], quantity: quantity_array[index].to_i})
    end

    fulfillment = ShopifyAPI::Fulfillment.new(order_id: @order.shopify_id, tracking_number: params[:tracking_number], tracking_url: params[:tracking_url], line_items: line_item_array, tracking_company: params[:shipping_carrier])
    if fulfillment.save
      @order.fulfillments.create(fulfillment_id: fulfillment.id, status: fulfillment.status, service: fulfillment.service, tracking_company: fulfillment.tracking_company, shipment_status: fulfillment.shipment_status, tracking_number: fulfillment.tracking_number, tracking_url: fulfillment.tracking_url, items: items_array)
      @order.update(fulfillment_status: ShopifyAPI::Order.find(:first, params: {id: @order.shopify_id}).fulfillment_status)
      fulfillment_service.update_line_items @order
      ProductService.new.update_fulfillable_quantity_descrease items_array_sku
      SupplyService.new.update_fulfillable_quantity_descrease items_array_sku, @order.shop_id
      fulfillment_service.calculator_quantity quantity_array, @order
      flash[:notice] = "Created succesfully"
      redirect_to order_path(@order)
    else
      fulfillment_service.update_line_items @order
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
