# class ProductsController < ShopifyApp::AuthenticatedController
class ProductsController < ApplicationController
  # TODO
  # sync products from shop
  before_action :set_product, only: [:show, :edit, :update, :destroy, :add_to_shop]

  # GET /products
  # GET /products.json
  def index
    @products = Product.all
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        if params[:product][:images]
          params[:product][:images].each do |img|
            @product.images.create(file: img)
          end
        end

        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        # format.json { render :show, status: :created, location: @product }
        format.json { render json: @product, status: :created }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        if params[:product][:images]
          params[:product][:images].each do |img|
        #params[:images].each do |key, value|
            @product.images.create(file: img)
          end
        end
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        # format.json { render :show, status: :ok, location: @product }
        format.json { render json: @product, status: :created }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_to_shop
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :weight, :length, 
                                      :height, :width, :sku, :desc, 
                                      :price, :cost, :shipping_price)
    end
end
