class OptionsController < ApplicationController
  load_and_authorize_resource :product
  load_and_authorize_resource :option, through: :product

  # GET /options
  # GET /options.json
  def index
    render json: @options
  end

  # POST /options
  # POST /options.json
  def create
    # @option = Option.new(option_params)
    respond_to do |format|
      format.json do
        if @option.save
          render json: @option
        else
          render json: { :errors => @option.errors.messages }, status: :unprocessable_entity
        end
      end
    end
  end

  # PATCH/PUT /options/1
  # PATCH/PUT /options/1.json
  def update
    respond_to do |format|
      format.json do 
        if @option.update(option_params)
          render json: @option
        else
          render json: { :errors => @option.errors.messages }, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /options/1
  # DELETE /options/1.json
  def destroy
    @option.destroy
    respond_to do |format|
      format.json { render :json => {}, :status => :no_content }
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def option_params
    # params.fetch(:option, {})
    if params[:option].key? 'values'
      params[:option][:values] = params[:option][:values].split(",")
    end
    params.require(:option).permit(:name, values: [])
  end
end
