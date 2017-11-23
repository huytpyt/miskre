class Api::V1::VariantsController < Api::V1::BaseController
	load_and_authorize_resource :product
  load_and_authorize_resource :variant, through: :product

  # GET /api/v1/products/:product_id/variants
  def index
    render :json => {status: true, variants: VariantsQuery.list(@product)}, status: 200
  end

  # POST /api/v1/products/:product_id/variants/reload
  def reload
    @product.regen_variants
    render :json => {status: true, variants: VariantsQuery.list(@product)}, status: 200
  end

  # POST /api/v1/products/:product_id/variants
  # def create
  # end

  # GET /api/v1/products/:product_id/variants/:id
  def show
  	render :json => {status: true, variant: VariantsQuery.single(@variant)}, status: 200
  end

  # PUT /api/v1/products/:product_id/variants/:id
  # {
  # 	"price": number,
  # 	"quantity": integer,
  #   "option1": string,
  #   "option2": string,
  #   "option3": string,
  #   "images": [image_id_1, image_id_2]
  # }
  def update
    if params[:variant].present?
    	if @variant.update(variant_params)
        if params[:variant][:images].present?
          if params[:variant][:images].is_a?(Array)
            exists_ids = params[:variant][:images].select{|id| Image.exists?(id)}
            @variant.image_ids = exists_ids
            @variant.save
          else
            render json: {status: false, error: "`images` must an array"}, status: 500
          end
        end
    		render :json => {status: true, variant: VariantsQuery.single(@variant)}, status: 200
    	else
    		render json: {status: false, :errors => @variant.errors.messages }, status: 500
    	end
    else
      render :json => {status: true, variant: VariantsQuery.single(@variant)}, status: 200
    end
  end

  # DELETE /api/v1/products/:product_id/variants/:id
  def destroy
  	@variant.destroy
    head :no_content
  end

  private

  	def variant_params
      params.require(:variant).permit(:option1, :option2, :option3, :quantity, :price, :user_id, :compare_at_price, :product_ids)
    end
end
