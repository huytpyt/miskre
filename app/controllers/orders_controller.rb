class OrdersController < ApplicationController
  before_action :set_query

  def index
  end

  def show
    @order = Order.find(params[:id])
  end

  def fetch
    respond_to do |format|
      format.csv { send_data @orders.to_csv, filename: "orders-#{@start_date}-#{@end_date}.csv" }
    end
  end

  private
  def set_query
    @start_date = params[:start_date] || Date.current - 7
    @end_date = params[:end_date] || Date.current
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
        @orders = @current_shop.orders.where(date: @start_date..@end_date).where(query_params)
      rescue ActiveRecord::RecordNotFound
        @current_shop = nil
        @orders = []
      end
    else
      unless current_user.shops.empty?
        @current_shop = current_user.shops.first
        @orders = @current_shop.orders.where(date: @start_date..@end_date).where(query_params)
      else
        @current_shop = nil
        @orders = []
      end
    end
  end
end
