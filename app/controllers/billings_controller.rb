class BillingsController < ApplicationController
  before_action :order_service, only: [:index, :show]
  before_action :get_billing, only: [:show, :update]
  def index
    @status = params[:status].to_s
    query_params = {}
    query_params['status'] = @status unless @status.empty?
    if current_user.staff?
      @shops = Shop.all
    else
      @shops = current_user.shops&.all
    end
    if params[:shop_id] && params[:shop_id] != ""
      begin
        @current_shop = @shops.find_by_id(params[:shop_id])
        @billings_orders = Order.where(shop_id: @current_shop.id, fulfillment_status: ["fulfilled", "fulfilling"])
      rescue
        @current_shop = nil
        @billings_orders = []
      end
    else
      @current_shop = nil
      @billings_orders = Order.where(fulfillment_status: ["fulfilled", "fulfilling"])
    end
  end

  def new
  end

  def show
  end

  def update
    if current_user.staff?
      @billing.update(params_billing)
      @billing.orders.each do |order|
        order.update(financial_status: params_billing[:status])
      end
      redirect_to billing_path(@billing), notice: "Update successfully!"
    end
  end

  def import
    if current_user.staff?
      require 'rubygems'
      require 'roo'
      require 'roo-xls'
      require 'csv'
      require 'iconv'
      spreadsheet = billing_service.open_spreadsheet(params[:file])
      if spreadsheet == false
        redirect_to new_billing_path, notice: "Unknown file type"
        return
      end
      
      billings_orders = billing_service.update_data spreadsheet

      if billings_orders[0].billings_orders.none?
        redirect_to billings_path, notice: billings_orders[1]
      else
        JobsService.delay.fulfillment billings_orders[0]
        redirect_to billings_path, notice: "Upload successfully!  #{billings_orders[1]}"
      end
    end
  end

  private
  def order_service
    @order_service ||= OrderService.new
  end

  def billing_service
    @billing_service ||= BillingService.new
  end
  def params_billing
    params.require(:billing).permit(:status)
  end

  def get_billing
    if current_user.staff?
      @billing = Billing.find(params[:id])
      @billings_orders = @billing.orders
    else
      shop_ids = current_user.shops.ids
      order_ids = Order.where(shop_id: shop_ids).ids
      billings_orders = BillingsOrder.where(order_id: order_ids)
      billing_ids = billings_orders.pluck(:billing_id).uniq
      @billings = Billing.where(id: billing_ids)

      @billing = @billings.find_by_id(params[:id])
      @billings_orders = @billing&.orders&.where(id: order_ids)
    end
  end
end