class ShippingSetingsController < ApplicationController
  before_action :get_shipping, only: [:edit, :update, :destroy]
  before_action :check_authorization, except: [:index, :update_carrier_service]
  before_action :admin_default_shipping_setting, only: [:index]

  def index
    @nations = current_user.user_nations
    @shops = current_user.shops
    if current_user == User.master_admin
      ceo = User.find_by_email("duy@miskre.com")
      @nations = ceo.user_nations if ceo.present?
    end
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

  def update_carrier_service
    shop = Shop.find params[:shop_id]
    result = ShopService.reset_carrier_service(shop)
    if result == true
      notice = 'Update succesfully.' 
    else
      notice = result
    end
    redirect_to shipping_setings_path, notice: notice
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

  def admin_default_shipping_setting
    return if current_user.user?
    ceo = User.ceo
    if ceo
      Nation.all.each do |nation|
        admin_nation = ceo.user_nations.find_or_create_by!(code: nation.code, name: nation.name)
        sync_this_nation(ceo, nation)
      end
    end
  end

  def sync_this_nation(admin, nation)
    nation.shipping_types.each do |shipping_type|
      admin_nation = admin.user_nations.find_by_code(nation.code) || admin.user_nations.create(code: nation.code, name: nation.name)
      admin_shipping_type = admin_nation.user_shipping_types.find_by_shipping_type_id(shipping_type.id) || admin_nation.user_shipping_types.create(shipping_type_id: shipping_type.id)
      admin_shipping_type.shipping_settings.create(min_price: 0, max_price: "infinity", percent: 100, packet_name: "#{shipping_type.code} (#{shipping_type.time_range})") unless admin_shipping_type.shipping_settings.present?
    end
  end
end
