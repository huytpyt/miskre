class SuppliesController < ApplicationController
  load_and_authorize_resource :supply

  def edit
  end

  def update
    respond_to do |format|
      if @supply.update(supply_params)
        if params[:supply][:images]
          params[:supply][:images].each do |img|
            @supply.images.create(file: img)
          end
        end
        format.html { redirect_to edit_supply_path(@supply), notice: 'Product was successfully updated.' }
      else
        format.html { render :edit }
      end
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
    product = @supply.product
    @supply.destroy
    redirect_to add_to_shop_product_url(product),
      notice: 'Product was successfully remove from shop.'
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def supply_params
    params.require(:supply).permit(:name, :price, :desc, :original)
  end
end
