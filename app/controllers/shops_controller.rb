class ShopsController < ApplicationController
  load_and_authorize_resource :shop

  # GET /shops
  # GET /shops.json
  def index
  end

  def products
    @shop = Shop.find_by_id(params[:id])
    @products = @shop&.products
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
end
