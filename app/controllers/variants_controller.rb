class VariantsController < ApplicationController
  load_and_authorize_resource :product
  load_and_authorize_resource :variant, through: :product

  def reload
    @product.regen_variants
    respond_to do |format|
      format.json do
        render json: @product.variants
      end
    end
  end

  # GET /variants
  # GET /variants.json
  def index
    render json: @variants
  end

  # POST /variants
  # POST /variants.json
  def create
    respond_to do |format|
      format.json do
        if @variant.save
          render json: @variant
        else
          render json: { :errors => @variant.errors.messages }, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    if  @product.shop_owner == true
      @shop = @product.shop
      product_ids = @shop.supplies.collect {|supply| supply.product.id if (supply.product.is_bundle == false) }
      product_ids = product_ids.compact
      @product_list = Product.where(id: product_ids).select(:id, :name)
    else
      @product_list = Product.where(is_bundle: false).select(:id, :name)
    end
  end

  # PATCH/PUT /variants/1
  # PATCH/PUT /variants/1.json
  def update
    respond_to do |format|
      if @product.is_bundle
        product_ids = params[:variant][:product_ids]&.map {|a| eval(a)} || []
        @variant.product_ids = product_ids
      end

      if @variant.update(variant_params)
        VariantService.update_variant @product, @variant
        if params[:variant][:images]
          params[:variant][:images].each do |img|
            @variant.images.create(file: img)
          end
        end

        format.html { redirect_to edit_product_variant_path(@product, @variant), notice: 'Variant was successfully updated.' }
        format.json { render json: @variant}
      else
        format.html { render :edit }
        format.json { render json: { :errors => @variant.errors.messages }, status: :unprocessable_entity }
      end
    end

    # respond_to do |format|
    #   format.json do 
    #     if @variant.update(variant_params)
    #       render json: @variant
    #     else
    #       render json: { :errors => @variant.errors.messages }, status: :unprocessable_entity
    #     end
    #   end
    # end
  end

  def upload_image_url
    image = @variant.images.new
    image.file_remote_url= params[:url]
    if image.save
      redirect_to edit_product_variant_path(@product, @variant),
        notice: 'Image was successfully updated.'
    else
      redirect_to edit_product_variant_path(@product, @variant),
        notice: 'Check your image URL.'
    end
  rescue
    redirect_to edit_product_variant_path(@product, @variant),
      notice: 'Check your image URL.'
  end

  # DELETE /variants/1
  # DELETE /variants/1.json
  def destroy
    @variant.destroy
    respond_to do |format|
      format.json { render :json => {}, :status => :no_content }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def variant_params
    params.require(:variant).permit(:quantity, :price, :sku)
  end
end
