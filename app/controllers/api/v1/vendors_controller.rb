class Api::V1::VendorsController < Api::V1::BaseController

  def create
    render json: VendorService.create(vendor_params, inventory_params), status: 200
  end

  def update
    render json: VendorService.update(params[:id], vendor_params, inventory_params), status: 200
  end

  def show
    data = VendorService.show(params[:id])
    if data[:result] == "Success"
      render json: VendorQuery.single(data[:vendor]), status: 200
    else
      render json: data, status: 200
    end
  end

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Vendor.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q] || ""

    render json: VendorQuery.list(page, per_page, sort, order_by, search), status: 200
  end

  def destroy
    render json: VendorService.destroy(params[:id].to_i)
  end

  private
    def vendor_params
      params.permit(:id, :name, :address, :phone, :email)
    end

    def inventory_params
      params.permit(:inventories)
    end
end
