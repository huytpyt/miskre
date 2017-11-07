class DetailNoHandlingsController < ApplicationController
  before_action :set_detail_no_handling, only: [:show, :edit, :update, :destroy]
  before_action :set_shipping_type
  before_action :authorization, except: [:index]

  def index
    @nation = Nation.find params[:nation_id]
    @detail_no_handlings = @shipping_type.detail_no_handlings.all
  end

  def new
    @detail_no_handling = DetailNoHandling.new
  end

  def edit
  end

  def create
    @detail_no_handling = @shipping_type.detail_no_handlings.new(detail_no_handling_params)
    if @detail_no_handling.save
      redirect_to nation_shipping_type_detail_no_handlings_path(params[:nation_id], params[:shipping_type_id]), notice: 'Detail no handling was successfully created.'
    else
      render :new
    end
  end

  def update
    if @detail_no_handling.update(detail_no_handling_params)
      redirect_to nation_shipping_type_detail_no_handlings_path(params[:nation_id], params[:shipping_type_id]), notice: 'Detail no handling was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @detail_no_handling.destroy
    redirect_to nation_shipping_type_detail_no_handlings_path(params[:nation_id], params[:shipping_type_id]), notice: 'Detail no handling was successfully destroyed.'
  end

  private
    def authorization
      unless current_user.staff?
        redirect_to root_path
      end
    end

    def set_shipping_type
      @shipping_type = ShippingType.find params[:shipping_type_id]
    end 

    def set_detail_no_handling
      @detail_no_handling = DetailNoHandling.find(params[:id])
    end

    def detail_no_handling_params
      params.require(:detail_no_handling).permit(:weight_from, :weight_to, :cost)
    end
end
