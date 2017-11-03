class RequestProductsController < ApplicationController
  before_action :set_request_product, only: [:show, :edit, :update, :destroy]

  def index
    unless current_user.staff?
      redirect_to root_path
      return
    end
    @request_products = RequestProduct.all
  end

  def show
  end

  def new
    @request_product = current_user.request_products.new
  end

  def edit
  end

  def create
    @request_product = current_user.request_products.new(request_product_params)

    respond_to do |format|
      if @request_product.save
        format.html { redirect_to @request_product, notice: 'Request product was successfully created.' }
        format.json { render :show, status: :created, location: @request_product }
      else
        format.html { render :new }
        format.json { render json: @request_product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @request_product.update(request_product_params)
        format.html { redirect_to @request_product, notice: 'Request product was successfully updated.' }
        format.json { render :show, status: :ok, location: @request_product }
      else
        format.html { render :edit }
        format.json { render json: @request_product.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @request_product.destroy
    respond_to do |format|
      format.html { redirect_to request_products_url, notice: 'Request product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_request_product
      @request_product = RequestProduct.find(params[:id])
    end

    def request_product_params
      params.require(:request_product).permit(:product_name, :link)
    end
end
