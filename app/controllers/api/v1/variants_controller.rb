class Api::V1::VariantsController < Api::V1::BaseController
	load_and_authorize_resource :product
  load_and_authorize_resource :variant, through: :product

  # GET /api/v1/products/:product_id/variants
  def index
    render :json => {status: true, variants: @product.variants}, status: 200
  end

  # POST /api/v1/products/:product_id/variants/reload
  def reload
    @product.regen_variants
    render :json => {status: true, variants: @product.variants}, status: 200
  end

  # POST /api/v1/products/:product_id/variants
  # def create
  # end

  # GET /api/v1/products/:product_id/variants/:id
  def show
  	render :json => {status: true, variants: @variant}, status: 200
  end

  # PUT /api/v1/products/:product_id/variants/:id
  # {
  # 	"price": number,
  # 	"quantity": integer,
  # 	"sku": string
  # }
  def update
  	if @variant.update(variant_params)
  		render :json => {status: true, variants: @variant}, status: 200
  	else
  		render json: {status: false, :errors => @variant.errors.messages }, status: 500
  	end
  end

  # DELETE /api/v1/products/:product_id/variants/:id
  def destroy
  	@variant.destroy
    head :no_content
  end

  private

  	def variant_params
    params.require(:variant).permit(:quantity, :price, :sku)
  end
end
