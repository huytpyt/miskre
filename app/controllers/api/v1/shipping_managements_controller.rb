class Api::V1::ShippingManagementsController < Api::V1::BaseController
  before_action :staff_authentication
  before_action :set_nation, only: [:destroy_nation, :shipping_types]
  before_action :set_shipping_type, only: [:destroy_shipping_type, :destroy_detail_shipping, :detail_shipping_types]

  def list_nations
    nations = Nation.all
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q]
    shipping_setting = false
    render json: ShippingsQuery.list(nations, page, per_page, sort, order_by, search, shipping_setting), status: 200
  end

  def destroy_nation
    @nation.destroy
    head :no_content
  end

  def destroy_shipping_type
    @shipping_type.destroy
    head :no_content
  end

  def destroy_detail_shipping
    detail_shipping_type = @shipping_type.has_handling ? DetailShippingType.find_by_id(params[:id]) : DetailNoHandling.find_by_id(params[:id])
    unless detail_shipping_type
      render json: {error: "Not found this detail shipping type"}, status: 404
      return
    else
      detail_shipping_type .destroy
      head :no_content
    end
  end

  def  shipping_types
    shipping_types = @nation.shipping_types
    render json: {nation: @nation, shipping_types: shipping_types}
  end

  def detail_shipping_types
    detail_shipping_types = @shipping_type.has_handling ? @shipping_type.detail_shipping_types.order(weight_from: :asc) : @shipping_type.detail_no_handlings.order(weight_from: :asc)
    render json: {shipping_type: @shipping_type, detail_shipping_types: detail_shipping_types}, status: 200
  end

  private

  def set_nation
    @nation = Nation.find(params[:id])
  end

  def set_shipping_type
    @shipping_type = ShippingType.find_by_id params[:shipping_type_id]
    unless @shipping_type
      render json: {error: "Not found this shipping type"}, status: 404
      return
    end
  end

  def staff_authentication
      unless current_resource.staff?
        render json: {status: false, message: "Permission denied"}, status: 550
      end
  end

end