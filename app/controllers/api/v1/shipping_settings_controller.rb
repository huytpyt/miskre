class Api::V1::ShippingSettingsController < Api::V1::BaseController
  before_action :set_shipping_type, only: [:change_status]
  def shippings_by_nation
    nations = current_user.user_nations
    if current_user == User.master_admin
      ceo = User.find_by_email("duy@miskre.com")
      nations = ceo.user_nations.page(params[:page]).per(10) if ceo.present?
    end
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = nations.size / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q]
    shipping_setting = true
    render json: ShippingsQuery.list(nations, page, per_page, sort, order_by, search, shipping_setting), status: 200
  end

  def change_status
    if @shipping_type.active
      @shipping_type.active = false
    else
      @shipping_type.active = true
    end
    if @shipping_type.save
      render json: {shipping_type: @shipping_type}, status: 200
    end
  end

  private
  def set_shipping_type
    @shipping_type = UserShippingType.find(params[:user_shipping_type_id])
  end
end