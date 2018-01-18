class Api::V1::TrackingInformationsController < Api::ApiController
  before_action :set_tracking_infor, only: [:show_info, :fetch_new_tracking_info]
  # def index
  #   page = params[:page].to_i || 1
  #   page = 1 if page.zero?
  #   per_page = params[:per_page].to_i || 20
  #   per_page = 20 if per_page.zero?
  #   total_page = Order.count / per_page
  #   total_page = total_page <= 0 ? 1 : total_page
  #   sort = params[:sort] || 'DESC'
  #   order_by = params[:order_by] || 'id'
  #   search = params[:q] || ""
  #   render json: TrackingInformationQuery.list(page, per_page, sort, order_by, search, current_resource), status: 200
  # end

  def show_info
    render json: TrackingInformationQuery.single(@tracking_information, @order), status: 200
  end

  def fetch_new_tracking_info
    TrackingInformationService.fetch_tracking_information @tracking_information.id
    render json: TrackingInformationQuery.single(@tracking_information.reload, @order), status: 200
  end

  private
  def set_tracking_infor
    @order = Order.find_by_shopify_id(params[:orderNo])
    @tracking_information = @order&.fulfillments&.first&.tracking_information
    unless @tracking_information
      render json: "", status: 404
      return
    end
  end
end
