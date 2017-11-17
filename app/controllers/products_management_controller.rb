class ProductsManagementController < ApplicationController
  def index
    @products = Product.all.order(id: :desc).page(params[:page])
    render layout: 'bootstrap'
  end

  def images_update
  	@product = Product.find(params[:product_id])
  	if @product
  		if params[:product] && params[:product][:images]
  			params[:product][:images].each do |img|
  				@product.images.create(file: img)
  			end
  		end
  	end
  	respond_to do |format|
	    format.html do
        redirect_to products_management_index_url
      end
      format.js
	  end
  end
end
