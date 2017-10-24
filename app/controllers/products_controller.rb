class ProductsController < ApplicationController
  # TODO
  # sync products from shop
  before_action :set_product, only: [:show, :edit, :update, :destroy,
                                     :upload_image_url,
                                     :add_to_shop, :assign, :remove_shop]
  before_action :check_is_staff, except: [:index, :show, :add_to_shop, :shipping, :assign, :new_bundle, :create_bundle, :update_bundle, :edit]

  # GET /products
  # GET /products.json
  def index
    # @products = Product.order(sku: :asc).page params[:page]
    user_ids = User.where.not(role: ["user"]).ids
    user_ids.push(current_user.id)
    product = Product.all
    @products = product.where(is_bundle: false)
    @bundle = current_user.staff? ? product.where(is_bundle: true) : product.where(is_bundle: true, user_id: user_ids)
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

  def shipping
    @product = Product.find(params[:product_id])
    cal_weight = (@product.length * @product.height * @product.width) / 5
    @weight = cal_weight > @product.weight ? cal_weight : @product.weight
  end
  # GET /products/new
  def new
    @product = Product.new
  end

  def new_bundle
    @product = Product.new
  end

  def create_bundle
    product_ids = params[:product][:product_ids]&.map {|a| eval(a)} || []
    @product = current_user.products.new(bundle_params)
    @product.is_bundle = true
    @product.product_ids = product_ids

    total_weight = 0
    total_cost = 0
    total_price = 0
    @product.product_ids.each do |id|
      product = Product.find(id[:product_id])
      weight = product.weight
      length = product.length
      height = product.height
      width = product.width

      cal_weight = (length * height * width) / 5
      weight = cal_weight > weight ? cal_weight : weight
      total_weight += width
      total_cost += product.cost
      total_price += product.suggest_price
    end

    @product.width = total_weight
    @product.cost = total_cost
    @product.suggest_price = (total_price * (100 - params[:sale_off].to_i))/100
    respond_to do |format|
      if @product.save
        ProductService.new.tracking_product_quantity(@product.quantity, @product)
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
        format.html { render :new_bundle }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_bundle
    @product = Product.find(params[:product_id])
    product_ids = params[:product][:product_ids]&.map {|a| eval(a)} || []
    
    respond_to do |format|
      @product.attributes = bundle_params

      if @product.quantity_changed? 
        ProductService.new.tracking_product_quantity(@product.quantity, @product)
      end
      if @product.product_ids != product_ids

        @product.product_ids = product_ids
        total_weight = 0
        total_cost = 0
        total_price = 0
        @product.product_ids.each do |id|
          product = Product.find(id[:product_id])
          weight = product.weight
          length = product.length
          height = product.height
          width = product.width
          cal_weight = (length * height * width) / 5
          weight = cal_weight > weight ? cal_weight : weight
          total_weight += weight
          total_cost += product.cost
          total_price += product.suggest_price
        end
        @product.weight = total_weight
        @product.cost = total_cost
        @product.suggest_price = ((total_price * (100 - bundle_params[:sale_off].to_i))/100).round(2)

        random = rand(2.25 .. 2.75)
        @product.variants.each do |variant|
          variant.product_ids = product_ids
          variant.price = @product.suggest_price
          variant.compare_at_price = (variant.price * random/ 5).round(0) * 5
          variant.save
        end
      else
        Variant.transaction do
          @product.variants.each do |variant|
            VariantService.update_variant @product, variant
          end
        end
      end
      if @product.save
        
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
        ProductService.new.tracking_product_quantity(@product.quantity, @product)
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
      @product.attributes = product_params
      @product.product_ids = product_ids
      if @product.quantity_changed? 
        ProductService.new.tracking_product_quantity(@product.quantity, @product)
      end
      if @product.suggest_price_changed? 
        random = rand(2.25 .. 2.75)
        @product.variants.each do |variant|
          variant.price = @product.suggest_price
          variant.compare_at_price = (variant.price * random/ 5).round(0) * 5
          variant.save
        end
      end
      if @product.save
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
    if @product.destroy
      @product.supplies&.destroy_all
    end
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_to_shop
    if @product.suggest_price.present?
      @available_shops = current_user.shops - @product.shops
      @supplies = @product.supplies.where(user_id: current_user.id)
    else
      redirect_to products_path, notice: 'Add suggest price please'
    end
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

  def report
    unless current_user.staff?
      redirect_to root_path
    end
  end
  
  def tracking_product
    array = []
    if current_user.staff?
      trackings = Product.find(params[:id]).tracking_products.where(created_at: get_start_date..get_end_date)
      trackings.each do |tracking|
        array.push(x: tracking.created_at, y: [tracking.open, tracking.high, tracking.low, tracking.close])
      end
    end
    render json: array
  end
  private
    def get_start_date
      if params[:start].present? && params[:start] != UNDEFINED
        DateTime.parse(params[:start])
      else
        (DateTime.now - 7.days).strftime(TIME_FORMAT)
      end
    end

    def get_end_date
      if params[:end].present? && params[:end] != UNDEFINED
        DateTime.parse(params[:end]).end_of_day
      else
        DateTime.now.strftime(TIME_FORMAT_END)
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:name, :weight, :length, :vendor, :is_bundle,
                                      :height, :width, :sku, :desc, :quantity,
                                      :price, :cost, :product_url, :suggest_price)
    end

    def bundle_params
      params.require(:product).permit(:name, :weight, :vendor, :is_bundle,
                                      :sku, :desc, :quantity,
                                      :price, :cost, :product_url, :suggest_price, :sale_off)
    end

    def check_is_staff
      unless current_user.staff?
        redirect_to :back
      end
    end
end
