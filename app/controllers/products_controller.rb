class ProductsController < ApplicationController
  # TODO
  # sync products from shop
  before_action :set_product, only: [:show, :edit, :update, :destroy,
                                     :upload_image_url,
                                     :add_to_shop, :assign, :remove_shop]

  # GET /products
  # GET /products.json
  def index
    # @products = Product.order(sku: :asc).page params[:page]
    @my_products = current_user.products.all
    @products = Product.where.not(id: @my_products.ids)
    respond_to do |format|
      format.json do
        render json: @products
      end
      format.html {}
    end
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
    product_ids = params[:product][:product_ids]&.map {|a| eval(a)} || []
    @product = current_user.products.new(product_params)
    @product.product_ids = product_ids
    respond_to do |format|
      if @product.save
        if params[:product][:images]
          params[:product][:images].each do |img|
            @product.images.create(file: img)
          end
        end

        # format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.html { redirect_to edit_product_path(@product), notice: 'Product was successfully created.' }
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
    product_ids = params[:product][:product_ids]&.map {|a| eval(a)} || []
    respond_to do |format|
      if @product.update(product_params)
        @product.product_ids = product_ids
        @product.save
        if params[:product][:images]
          params[:product][:images].each do |img|
        #params[:images].each do |key, value|
            @product.images.create(file: img)
          end
        end
        format.html { redirect_to edit_product_path(@product), notice: 'Product was successfully updated.' }
        # format.json { render :show, status: :ok, location: @product }
        format.json { render json: @product, status: :created }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload_image_url
    image = @product.images.new
    image.file_remote_url= params[:url]
    if image.save
      redirect_to edit_product_path(@product), notice: 'Image was successfully updated.'
    else
      redirect_to edit_product_path(@product), notice: 'Check your image URL.'
    end
  rescue
    redirect_to edit_product_path(@product), notice: 'Check your image URL.'
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
    @available_shops = current_user.shops - @product.shops
    @supplies = @product.supplies.where(user_id: current_user.id)
  end

  def assign
    shop_ids = params[:product][:shops]
    unless shop_ids.empty?
      shop_ids.each do |id|
        c = ShopifyCommunicator.new(id)
        c.add_product(@product.id)
      end
    end
    redirect_to add_to_shop_product_path(@product), notice: 'Product has been added to shops.'
  end

  def purchases
    csv = CSV.generate do |csv|
      csv << ["ProductName", "SKU", "Quantity", "Link"]
      Product.order(sku: :asc).each do |p|
        if p.variants.count <= 1
          csv << [p.name, p.sku, 6, p.link]
        else
          first = true
          p.variants.each do |v|
            if first
              csv << [p.name, v.sku + " - " + v.option1, 4, p.link]
              first = false
            else
              csv << ["", v.sku + " - " + v.option1, 4, ""]
            end
          end
        end

        csv << []
      end
    end

    send_data csv, filename: "purchase_list.csv"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :weight, :length, :vendor, :is_bundle,
                                      :height, :width, :sku, :desc, :quantity,
                                      :price, :cost)
    end
end
