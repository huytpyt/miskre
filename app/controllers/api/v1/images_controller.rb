class Api::V1::ImagesController < Api::V1::BaseController
	before_action :validate_image_base64, only: :create
	before_action :prepare_image, only: [:show, :destroy]

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
