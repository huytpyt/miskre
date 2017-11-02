class ShippingTypesController < ApplicationController
  before_action :set_shipping_type, only: [:show, :edit, :update, :destroy]
  before_action :set_nation
  before_action :authorization

  def index
    @shipping_types = @nation.shipping_types.all
  end

  def new
    @shipping_type = ShippingType.new
  end

  def edit
  end

  def create
    @shipping_type = @nation.shipping_types.new(shipping_type_params)
    if @shipping_type.save
      redirect_to nation_shipping_types_path(params[:nation_id]), notice: 'Shipping type was successfully created.' 
    else
      render :new
    end
  end

  def update
    if @shipping_type.update(shipping_type_params)
      redirect_to nation_shipping_types_path(params[:nation_id]), notice: 'Shipping type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @shipping_type.destroy
    redirect_to nation_shipping_types_path(params[:nation_id]), notice: 'Shipping type was successfully destroyed.' 
  end

  private
    def authorization
      unless current_user.staff?
        redirect_to root_path
      end
    end

    def set_shipping_type
      @shipping_type = ShippingType.find(params[:id])
    end

    def shipping_type_params
      params.require(:shipping_type).permit(:code, :time_range, :has_handling)
    end

    def set_nation
      @nation = Nation.find params[:nation_id]
    end
end
