class OrdersController < ApplicationController
  before_action :set_query

  def index
    if params[:download].present?
      xls_string = CSV.generate(headers:true) do |csv|
        column_names =  ["Order Id", "First Name", "Last Name",
                         "Ship Address1", "Ship Address2", "Ship City",
                         "Ship State", "Ship Zip", "Ship Country",
                         "Ship Phone", "Email", "Quantity", "SKUs Info (SKU*Quantity)",
                         "Unit Price(price1,price2...)", "Date", "Remark", "Shipping Method",
                         "Tracking No.", "Fulfil Fee$", "Product Name", "Color", "Size"]
        csv << column_names
        @orders.each do |order|
          skus = []
          skus_array = order.skus.split(",")
          skus_array.each do |item|
            sku_item = item.split("*")
            sku = sku_item[0].strip
            quantity = sku_item[1]
            product = Product.find_by_sku(sku&.first(3))
            if product&.is_bundle
              if product.variants.present?
                variant = Variant.find_by_sku sku
                variant.product_ids.each do |id|
                  if id[:variant_id].nil?
                    skus.push("#{Product.find(id[:product_id]).sku} * #{quantity}") 
                  else
                     skus.push("#{Variant.find(id[:variant_id]).sku} * #{quantity}")
                  end
                end
              else
                product.product_ids.each do |id|
                  if id[:variant_id].nil?
                    skus.push("#{Product.find(id[:product_id]).sku} * #{quantity}") 
                  else
                     skus.push("#{Variant.find(id[:variant_id]).sku} * #{quantity}")
                  end
                end
              end
            else
              skus.push("#{sku} * #{quantity}")
            end
          end
              
          row = [order.shopify_id, order.first_name, order.last_name,
                 order.ship_address1, order.ship_address2,
                 order.ship_city, order.ship_state,
                 order.ship_zip, order.ship_country,
                 order.ship_phone, "",
                 order.quantity, skus.join(","), "", order.date,
                 "remark", order.shipping_method, "", "", order.product_name,
                 "Color", "Size"]
          csv << row
        end
      end
      send_data xls_string, :type => "text/plain", 
           :filename=>"orders-#{@start_date}-#{@end_date}.csv",
           :disposition => 'attachment'
    end
  end

  def show
    @order = Order.find(params[:id])
    @sum = @order.line_items.sum(:fulfillable_quantity)
    @fulfillments = @order.fulfillments.all
  end

  def fetch_orders 
    ShopService.delay.sync_orders
    redirect_to orders_path
  end

  private
  def set_query
    @start_date = params[:start_date]&.to_date || Date.current - 7
    @end_date = params[:end_date]&.to_date || Date.current
    @financial_status = params[:financial_status].to_s
    @fulfillment_status = params[:fulfillment_status].to_s

    query_params = {}
    if @fulfillment_status == "null"
      query_params['fulfillment_status'] = nil
    else
      query_params['fulfillment_status'] = @fulfillment_status unless @fulfillment_status.empty?
    end
    query_params['financial_status'] = @financial_status unless @financial_status.empty?

    if params[:shop_id]
      begin
        @current_shop = Shop.find(params[:shop_id])
        @orders = @current_shop.orders.where(date: @start_date.beginning_of_day..@end_date.end_of_day).where(query_params)
      rescue ActiveRecord::RecordNotFound
        @current_shop = nil
        @orders = []
      end
    else
      unless current_user.shops.empty?
        @current_shop = current_user.shops.first
        @orders = @current_shop.orders.where(date: @start_date.beginning_of_day..@end_date.end_of_day).where(query_params)
      else
        @current_shop = nil
        @orders = []
      end
    end
  end
end
