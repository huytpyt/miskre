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
  end

  # PATCH/PUT /variants/1
  # PATCH/PUT /variants/1.json
  def update
    respond_to do |format|
      if @variant.update(variant_params)
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
