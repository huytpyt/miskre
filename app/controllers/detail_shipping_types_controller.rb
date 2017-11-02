class DetailShippingTypesController < ApplicationController
  before_action :set_detail_shipping_type, only: [:show, :edit, :update, :destroy]
  before_action :set_shipping_type
  before_action :authorization

  def index
    @nation = Nation.find params[:nation_id]
    @detail_shipping_types = @shipping_type.detail_shipping_types.all
  end

  def new
    @detail_shipping_type = DetailShippingType.new
  end

  def edit
  end

  def create
    @detail_shipping_type = @shipping_type.detail_shipping_types.new(detail_shipping_type_params)
    if @detail_shipping_type.save
      redirect_to nation_shipping_type_detail_shipping_types_path(params[:nation_id], params[:shipping_type_id]), notice: 'Detail shipping type was successfully created.'
    else
      render :new
    end
  end

  def update
    if @detail_shipping_type.update(detail_shipping_type_params)
      redirect_to nation_shipping_type_detail_shipping_types_path(params[:nation_id], params[:shipping_type_id]), notice: 'Detail shipping type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @detail_shipping_type.destroy
    redirect_to nation_shipping_type_detail_shipping_types_path(params[:nation_id], params[:shipping_type_id]), notice: 'Detail shipping type was successfully destroyed.' 
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

    def set_detail_shipping_type
      @detail_shipping_type = DetailShippingType.find(params[:id])
    end

    def detail_shipping_type_params
      params.require(:detail_shipping_type).permit(:weight_from, :weight_to, :cost, :handling_fee)
    end
end
