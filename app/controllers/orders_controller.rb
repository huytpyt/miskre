class OrdersController < ApplicationController
  before_action :set_query

  def index
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

    if params[:shop_id]
      begin
        @current_shop = Shop.find(params[:shop_id])
        @orders = @current_shop.orders.where(date: @start_date..@end_date)
      rescue ActiveRecord::RecordNotFound
        @current_shop = nil
        @orders = []
      end
    else
      unless current_user.shops.empty?
        @current_shop = current_user.shops.first
        @orders = @current_shop.orders.where(date: @start_date..@end_date)
      else
        @current_shop = nil
        @orders = []
      end
    end
  end
end
