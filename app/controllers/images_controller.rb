class ImagesController < ApplicationController

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    image = Image.find(params[:id])
    # product = image.product
    type = image.imageable_type
    parent = image.imageable
    image.destroy

    if type == 'Product'
      redirect_to edit_product_path(parent), notice: 'Image was successfully destroyed.'
    else
      redirect_to edit_product_variant_path(parent.product, parent), notice: 'Image was successfully destroyed.'
    end
  end
end
