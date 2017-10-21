class ShopsController < ApplicationController
  load_and_authorize_resource :shop

  # GET /shops
  # GET /shops.json
  def index
  end

  def show
    @products = params[:search].present? ? @shop.products.search(params[:search]).records : @shop.products.all
    @products = @products.page(params[:page])
    @global_settting = @shop.global_setting_enable
  end

  def global_price_setting
    @shop = Shop.find(params[:shop_id])
    @shop.update(global_price_setting_params)
    ShopService.update_supply @shop
    redirect_to @shop, notice: "Update successfully!"
  end

  def change_price_option
    @shop = Shop.find(params[:shop_id])
    if @shop.global_setting_enable == true
      @shop.global_setting_enable = false
      ShopService.update_price_suggest @shop
      message = "suggested price option"
    else
      @shop.global_setting_enable = true
      ShopService.update_price_global_setting @shop
      message = "global price setting option"
    end
    if @shop.save
      redirect_to @shop, notice: "Change to #{message} successfully!"
    end
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
    supplies = Supply.where(shop_id: params[:id]).where.not(fulfillable_quantity: nil).order(fulfillable_quantity: :DESC).select(:name, :fulfillable_quantity).first(15)
    supplies.each do | supply|
      array.push({ label: supply.name,  y: supply.fulfillable_quantity || 0})
    end
    render json: array
  end

  def reports
  end

  def shipping
    @shop = Shop.find params[:shop_id]
    @supply = Supply.find(params[:supply_id])
    @product = @supply.product
    cal_weight = (@product.length * @product.height * @product.width) / 5
    @weight = cal_weight > @product.weight ? cal_weight : @product.weight
  end

  private

  def global_price_setting_params
    params.require(:shop).permit(:cost_rate, :shipping_rate)
  end
end
