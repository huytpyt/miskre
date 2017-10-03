class ReportsController < ApplicationController
  def index
    unless current_user.staff?
      redirect_to root_path
    end
  end

  def product_orders_unfulfilled
    array = []
    if current_user.staff?
      products = Product.where.not(fulfillable_quantity: nil).order(fulfillable_quantity: :DESC).select(:name, :fulfillable_quantity).first(15)
      products.each do | product|
        array.push({ label: product.name,  y: product.fulfillable_quantity || 0})
      end
    end
    render json: array
  end
end
