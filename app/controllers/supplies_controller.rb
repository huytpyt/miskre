class SuppliesController < ApplicationController
  load_and_authorize_resource :supply
  before_action :set_variant, only: [:edit_variant, :update_variant]
  def edit
  end

  def update
    @supply.attributes = supply_params
    if @supply.price_changed? || @supply.compare_at_price_changed?
      @supply.supply_variants.each do | variant|
        variant.update(price: @supply.price, compare_at_price: @supply.compare_at_price)
      end
    end
    if @supply.update(supply_params)
      if params[:supply][:images]
        params[:supply][:images].each do |img|
          @supply.images.create(file: img)
        end
      end
      JobsService.delay.sync_this_supply @supply.id
      redirect_to edit_supply_path(@supply), notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def upload_image_url
    image = @supply.images.new
    image.file_remote_url= params[:url]
    if image.save
      redirect_to edit_supply_path(@supply),
        notice: 'Image was successfully updated.'
    else
      redirect_to edit_supply_path(@supply), notice: 'Check your image URL.'
    end
  rescue
    redirect_to edit_supply_path(@supply), notice: 'Check your image URL.'
  end

  def destroy
    shop = @supply.shop
    @supply.is_deleted = true
    @supply.shop_id = nil
    if @supply.save
      @supply.images.destroy_all
      @supply.supply_variants.each {|supply_variant| supply_variant.images.destroy_all}
      JobsService.delay.remove_shopify_product shop.id, @supply.shopify_product_id
    end
    redirect_to shop_url(shop), notice: 'Product was successfully removed from shop.'
  end

  def edit_variant
  end

  def update_variant
    @variant.update(variant_params)
    redirect_to edit_supply_path(@supply), notice: "Update variant price successfully"
  end

  private

  def set_variant
    @supply = Supply.find params[:supply_id]
    @variant = SupplyVariant.find params[:variant_id]
  end
  # Never trust parameters from the scary internet, only allow the white list through.

  def variant_params
    params.require(:supply_variant).permit(:price, :compare_at_price, :option1, :option2, :option3)
  end
  def supply_params
    params.require(:supply).permit(:name, :price, :desc, :original, :keep_custom, :compare_at_price)
  end
end
