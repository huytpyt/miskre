class Api::V1::TrackingInformationsController < Api::V1::BaseController

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Order.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q] || ""
    render json: TrackingInformationQuery.list(page, per_page, sort, order_by, search, current_resource), status: 200
  end

  def show
    tracking_information = TrackingInformation.find(params[:id])
    render json: TrackingInformationQuery.single(tracking_information), status: 200
  end

  def fetch_new_tracking_info
    tracking_information = TrackingInformation.find(params[:tracking_information_id])
    TrackingInformationService.fetch_tracking_information params[:tracking_information_id]
    render json: TrackingInformationQuery.single(tracking_information.reload), status: 200
  end
end
