class Api::V1::InventoriesController < Api::V1::BaseController

  def index
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    total_page = Inventory.count / per_page
    total_page = total_page <= 0 ? 1 : total_page
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:search] || ""
    render json: InventoriesQuery.list(page, per_page, sort,
      order_by, search, current_resource), status: 200
  end

  def show
    inventory = Inventory.find(params[:id])
    render json: InventoriesQuery.single(inventory)
  end

  def update
    result, errors, inventory = InventoryService.update(params[:id], inventory_params, inventory_variant_params)
    render json: { result: result, errors: errors, inventory: inventory }, status: 200
  end

  def create
    result, errors, inventory = InventoryService.create(inventory_params, inventory_variant_params)
    render json: { result: result, errors: errors, inventory: inventory }, status: 200
  end

  def destroy
    result, errors, inventory = InventoryService.destroy(params[:id])
    render json: { result: result, errors: errors, inventory: inventory }, status: 200
  end

  private
    def inventory_params
      params.permit(:id, :product_id, :quantity, :cost)
    end

    def inventory_variant_params
      params.permit(:variants)
    end
end
