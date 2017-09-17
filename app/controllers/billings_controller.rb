class BillingsController < ApplicationController
  before_action :order_service, only: [:index, :show]
  before_action :get_billing, only: [:show, :update]
  def index
    @billings = Billing.all
  end

  def new
  end

  def show
  end

  def update
    if current_user.staff?
      @billing.update(params_billing)
      shopify_order_ids = @billings_orders.pluck(:order_shopify_id)
      Order.where(shopify_id: shopify_order_ids).each do |order|
        order.update(financial_status: "paid")
      end
      redirect_to billing_path(@billing), notice: "Update successfully!"
    end
  end

  def import
    require 'rubygems'
    require 'roo'
    require 'roo-xls'
    require 'csv'
    require 'iconv'
    billing = Billing.import(params[:file])
    if billing.present?
      redirect_to billing_path(billing), notice: "Products imported."
    else
      redirect_to billings_path, notice: "Something went wrong!"
    end
  end

  private
  def order_service
    @order_service ||= OrderService.new
  end

  def params_billing
    params.require(:billing).permit(:status)
  end

  def get_billing
    @billing = Billing.find(params[:id])
    @billings_orders = @billing.billings_orders
  end
end