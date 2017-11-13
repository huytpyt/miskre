class ProductsManagementController < ApplicationController
  def index
    @products = Product.all.order(id: :desc).page(params[:page])
    render layout: 'bootstrap'
  end
end
