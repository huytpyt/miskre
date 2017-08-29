require 'csv'

# class OrdersController < ShopifyApp::AuthenticatedController
class OrdersController < ApplicationController
  before_action :set_query

  def index
    # shopify_params = {
    #   financial_status: 'paid', 
    #   fulfillment_status: ['partial', 'unshipped'],
    #   limit: 10
    # }
    # @orders_number = ShopifyAPI::Order.find(:count, params: shopify_params).count
    # @orders = ShopifyAPI::Order.find(:all, params: shopify_params)
    #
    if current_user.shops.empty?
      @orders_number = 0
      @orders = []
    else
      # session[:shopify] ||= current_user.shops.first.id
      c = ShopifyCommunicator.new(current_user.shops.first.id)
      c.add_product(@product.id)
      @orders_number = c.count_order()
      @orders = c.sample_order()
    end
  end

  def fetch
    session[:shopify] = params[:shop_id]

    if params[:commit] == "View"
      redirect_to action: :index, start_date: @start_date, end_date: @end_date, shop_id: @current_shop
    elsif params[:commit] == "Download"
      shopify_params = {
        financial_status: 'paid', 
        fulfillment_status: ['partial', 'unshipped']
      }
      @orders = ShopifyAPI::Order.find(:all, params: shopify_params)

      csv = CSV.generate do |csv|
        column_names =  ["OrderId", "First Name", "Last Name", 
                         "Ship Address1", "Ship Address2", "Ship City", 
                         "Ship State", "Ship Zip", "Ship Country", 
                         "Ship Phone", "Email", "Quantity", "SKUs Info", 
                         "Unit Price", "Date", "Remark", "Shipping Method", 
                         "Tracking No.", "Fulfill Fee", "Product Name", 
                         "Color", "Size"]
        csv << column_names
        @orders.each do |order|
          quantity = 0
          skus = []
          unit_prices = []
          shipping_methods = []
          products = []

          order.line_items.each do |item|
            quantity += item.quantity
            skus.append("#{item.sku} * #{item.quantity}")
            unit_prices.append(item.price)
            products.append(item.title)
          end

          order.shipping_lines.each do |s|
            shipping_methods.append(s.title)
          end

          row = [order.id, order.customer.first_name, order.customer.last_name,
                 order.shipping_address.address1, order.shipping_address.address2,
                 order.shipping_address.city, order.shipping_address.province,
                 order.shipping_address.zip, order.shipping_address.country,
                 order.shipping_address.phone, order.customer.email,
                 quantity, skus.join(","), unit_prices.join(","), order.created_at,
                 "remark", shipping_methods.join(","), "0", "0", products.join(","),
                 "Color", "Size"]

          csv << row
        end
      end

      send_data csv, filename: "orders.xls"
    end
  end

  private 

  def set_query
    # session[:shopify] ||= params[:shop_id]
    @current_shop = session[:shopify]
    @start_date = params[:start_date] || Date.current - 7
    @end_date = params[:end_date] || Date.current
  end
end
