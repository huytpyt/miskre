class ShippingSetingsController < ApplicationController
  before_action :get_shipping, only: [:edit, :update, :destroy]
  before_action :check_authorization, except: [:index]

  def index
    @nations = current_user.user_nations
  end

  def setting
    @shipping = ShippingSetting.where(user_shipping_type_id: params[:shipping_type_id])
  end

  def new
    last_shipping = ShippingSetting.where(user_shipping_type_id: params[:shipping_type_id])&.last
    @shipping = ShippingSetting.new
    @shipping.min_price = last_shipping.max_price unless last_shipping.nil?
  end

  def create
    shipping_type = UserShippingType.find(params[:shipping_type_id])
    shipping = shipping_type.shipping_settings.new(get_shipping_params)
    if params[:mark_infinity].present?
      shipping.max_price = "infinity"
    end
    if shipping.save
      redirect_to setting_shipping_setings_path(params[:shipping_type_id]), notice: "Create succesfully"
    end
  end

  def update
    if params[:mark_infinity].present?
      @shipping.max_price = "infinity"
    end
    @shipping.attributes = get_shipping_params
    @shipping.save
    redirect_to setting_shipping_setings_path(params[:shipping_type_id]), notice: "Update succesfully"
  end

  def destroy
    @shipping.destroy
    redirect_to setting_shipping_setings_path(params[:shipping_type_id]), notice: "Destroy succesfully"
  end

  def change_status
    shipping_type = UserShippingType.find(params[:shipping_type_id])
    if shipping_type.active
      shipping_type.active = false
    else
      shipping_type.active = true
    end
    if shipping_type.save
      redirect_to shipping_setings_path
    end
  end

  private
  def get_shipping
    @shipping = ShippingSetting.find params[:id]
  end

  def get_shipping_params
    params.require(:shipping_setting).permit(:min_price, :max_price, :packet_name, :percent)
  end

  def check_authorization
    shipping_type = UserShippingType.find(params[:shipping_type_id])
    unless shipping_type&.user_nation&.user == current_user
      redirect_to root_path
    end
  end
end
