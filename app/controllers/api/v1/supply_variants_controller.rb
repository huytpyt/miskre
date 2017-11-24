class Api::V1::SupplyVariantsController < Api::V1::BaseController
  load_and_authorize_resource :supply_variant
  def show
    render json: {supply_variant: @supply_variant}, status: 200
  end

  def update
    if @supply_variant.update(variant_params)
      render json: {supply_variant: @supply_variant}, status: 200
    else
      render json: {error: "Something went wrong!"}, status: 500
    end
  end

  def variant_params
    params.permit(:price, :compare_at_price, :option1, :option2, :option3)
  end
end