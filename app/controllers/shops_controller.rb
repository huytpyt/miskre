class ShopsController < ApplicationController
  load_and_authorize_resource :shop

  # GET /shops
  # GET /shops.json
  def index
  end

  def show
    @products = params[:search].present? ? @shop.products.search(params[:search]).records : @shop.products.all
    @products = @products.page(params[:page])
  end

  # DELETE /shops/1
  # DELETE /shops/1.json
  def destroy
    @shop.destroy
    respond_to do |format|
      format.html { redirect_to shops_path, notice: 'Shop was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def supply_orders_unfulfilled
    array = []
    supplies = Supply.where.not(fulfillable_quantity: nil).order(fulfillable_quantity: :DESC).select(:name, :fulfillable_quantity).first(15)
    supplies.each do | supply|
      array.push({ label: supply.name,  y: supply.fulfillable_quantity || 0})
    end
    render json: array
  end

  def reports
  end
end
