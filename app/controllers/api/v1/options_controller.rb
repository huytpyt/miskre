class Api::V1::OptionsController < Api::V1::BaseController
	load_and_authorize_resource :product
  load_and_authorize_resource :option, through: :product

  # GET /api/v1/products/:product_id/options
  def index
    render :json => {status: true, options: @options}, status: 200
  end

  # POST /api/v1/products/:product_id/options
 	#  {
	# 	"name": text,
	# 	"values": text, (val1, val2, val3)
	# }
  def create
  	if @option.save
      render json: {status: true, option: @option}, status: 200
    else
      render json: {status: false, :errors => @option.errors.messages }, status: 500
    end
  end

  # GET /api/v1/products/:product_id/options/:id
  def show
  	render json: {status: true, option: @option}, status: 200
  end

  # PUT /api/v1/products/:product_id/options/:id
 	#  {
	# 	"name": text,
	# 	"values": text, (val1, val2, val3)
	# }
  def update
  	if @option.update(option_params)
      render json: {status: true, option: @option}, status: 200
    else
      render json: {status: false, :errors => @option.errors.messages }, status: 500
    end
  end

  # DELETE /api/v1/products/:product_id/options/:id
  def destroy
  	@option.destroy
    head :no_content
  end

  private

  	def option_params
  		if params[:option].key? 'values'
	      params[:option][:values] = params[:option][:values].split(",")
	    end
	    params.require(:option).permit(:name, values: [])
  	end

end
