class ShippingsController < ApplicationController
  before_action :get_shipping, only: [:edit, :update, :destroy]
  def index
    @shipping = current_user.shippings.all
    unless current_user.shippings.present?
      current_user.shippings.create(min_price: 0, max_price: 35, name_epub: "Insured Shipping", name_dhl: "Expedited Insured Shipping", percent_epub: 100, percent_dhl: 100)
      current_user.shippings.create(min_price: 35, max_price: "infinity", name_epub: "Free Insured Shipping", name_dhl: "DHL (not free)", percent_epub: 0, percent_dhl: 100)
    end
  end

  def new
    last_shipping = current_user.shippings.last
    @shipping = current_user.shippings.new
    @shipping.min_price = last_shipping.max_price unless last_shipping.nil?
  end

  def edit
  end

  def create
    shipping = current_user.shippings.new(get_shipping_params)
    if shipping.save
      redirect_to shippings_path, notice: "Create succesfully"
    end
  end

  def update
    if params[:mark_infinity].present?
      @shipping.max_price = "infinity"
    end
    @shipping.attributes = get_shipping_params
    @shipping.save
    redirect_to shippings_path, notice: "Update succesfully"
  end

  def destroy
    @shipping.destroy
    redirect_to shippings_path, notice: "Destroy succesfully"
  end

  private

  def get_shipping
    @shipping = Shipping.find params[:id]
  end
  def get_shipping_params
    params.require(:shipping).permit(:min_price, :max_price, :name_epub, :name_dhl, :percent_epub, :percent_dhl)
  end
end
