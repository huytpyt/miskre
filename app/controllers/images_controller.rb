class ImagesController < ApplicationController

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    image = Image.find(params[:id])
    product = image.product
    image.destroy

    redirect_to edit_product_path(product), notice: 'Image was successfully destroyed.'
  end
end
