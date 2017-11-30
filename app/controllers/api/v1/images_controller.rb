class Api::V1::ImagesController < Api::V1::BaseController
	before_action :validate_image_base64, only: :create
	before_action :prepare_image, only: [:show, :destroy]

	def index
		page = params[:page].to_i || 1
    		page = 1 if page.zero?
    		per_page = params[:per_page].to_i || 20
    		per_page = 20 if per_page.zero?
    		total_page = Image.count / per_page
    		total_page = total_page <= 0 ? 1 : total_page
	    sort = params[:sort] || 'DESC'
	    order_by = params[:order_by] || 'id'
	    render json: ImagesQuery.list(page, per_page, sort, order_by), status: 200
	end

  	def create
  		image = Image.new
    		image.set_image_base64(params[:image])
    		if image.save
    			render :json => { status: true, image: ImagesQuery.single(image)}, status: 200
    		else
    			render json: {status: false, error: "Can not upload this image!"}, status: 500
    		end
  	end

	def show
		render :json => { status: true, image: ImagesQuery.single(@image) }, status: 200
	end

  	def destroy
    		@image.destroy
    		head :no_content
  	end

  	private

  	def validate_image_base64
  		if params[:image].present?
			true
		else
			render json: {status: false, error: "Image can't be blank"}, status: 500
		end
	end

	def prepare_image
	  	@image = Image.find(params[:id])
	rescue
	  	render json: {status: false, error: "Not found!"}, status: 404
	end
end
