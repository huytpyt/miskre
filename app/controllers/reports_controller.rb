class ReportsController < ApplicationController
  def index
  end

  def product_orders_unfulfilled
    array = []
    products = Product.order(fulfillable_quantity: :ASC).select(:name, :fulfillable_quantity).first(15)
    products.each do | product|
      array.push({ label: product.name,  y: product.fulfillable_quantity || 0})
    end
    render json: array
  end
end
