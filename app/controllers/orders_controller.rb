class OrdersController < ApplicationController
  before_action :set_query

  def index
    if params[:download].present?
      xls_string = CSV.generate(headers:true) do |csv|
        column_names =  ["Order No.", "Shipping Way", "Country", "Weight (KG)", "Quantity", "Received Name", "Full Adress", "Tel No.", "Post code", "State", "City", "Description", "Declared Name", "Declared Value (USD)", "SKU", "Tracking No."]
        csv << column_names
        @orders.each do |order|
          skus = []
          product_names = []
          skus_array = order.skus.split(",")
          weight = 0
          skus_array.each do |item|
            sku_item = item.split("*")
            sku = sku_item[0].strip
            quantity = sku_item[1]
            product = Product.find_by_sku(sku&.first(3))
            weight +=  ((product.weight.to_f * quantity.to_i).to_f/1000).round(3)
            if product&.is_bundle
              if product.variants.present?
                variant = Variant.find_by_sku sku
                variant.product_ids.each do |id|
                  product_found = Product.find(id[:product_id])
                  if id[:variant_id].nil?
                    skus.push("#{product_found.sku} * #{quantity}")
                    product_names.push("#{product_found.name} * #{quantity}")
                  else
                    variant_found = Variant.find(id[:variant_id]) 
                    skus.push("#{variant_found.sku} * #{quantity}")
                    product_names.push("#{ProductService.variant_name(product_found.name, variant_found)} * #{quantity}")
                  end
                end
              else
                product.product_ids.each do |id|
                  product_found = Product.find(id[:product_id])
                  if id[:variant_id].nil?
                    skus.push("#{product_found.sku} * #{quantity}")
                    product_names.push("#{product_found.name} * #{quantity}") 
                  else
                    variant_found = Variant.find(id[:variant_id]) 
                    skus.push("#{variant_found.sku} * #{quantity}")
                    product_names.push("#{ProductService.variant_name(product_found.name, variant_found)} * #{quantity}")
                  end
                end
              end
            else
              skus.push("#{sku} * #{quantity}")
              if product.variants.present?
                variant_found = Variant.find_by_sku sku
                product_names.push("#{ProductService.variant_name(product.name, variant_found)} * #{quantity}")
              else
                product_names.push("#{product.name} * #{quantity}")
              end
            end
          end
          country_code_found = ISO3166::Country.find_by_name(order.ship_country)
          if country_code_found.present?
            country_code_found = country_code_found[0]
          end
          country_code = order.country_code || country_code_found || order.ship_country
          row = [order.shopify_id, 
            order.shipping_method, 
            country_code, 
            weight, 
            order.quantity, 
            order.fullname, 
            order.full_address, 
            "", 
            order.ship_zip, 
            order.ship_state, 
            order.ship_city, 
            product_names.join(", "), 
            "", 
            "", 
            skus.join(", "),
            ""]
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
    @tracking_number_real = params[:tracking_number_real].to_s
    query_params = {}
    if @fulfillment_status == "null"
      query_params['fulfillment_status'] = nil
    else
      query_params['fulfillment_status'] = @fulfillment_status unless @fulfillment_status.empty?
    end
    query_params['financial_status'] = @financial_status unless @financial_status.empty?
    query_params['tracking_number_real'] = @tracking_number_real unless @tracking_number_real.empty?
    if params[:shop_id] && params[:shop_id] != ""
      begin
        @current_shop = Shop.find(params[:shop_id])
        @orders = @current_shop.orders.where(date: @start_date.beginning_of_day..@end_date.end_of_day).where(query_params)
      rescue ActiveRecord::RecordNotFound
        @current_shop = nil
        @orders = []
      end
    else
      @current_shop = nil
      @orders = Order.where(date: @start_date.beginning_of_day..@end_date.end_of_day, shop_id: current_user.staff? ? Shop.all.ids : current_user.shops.ids).where(query_params)
    end
  end
end
