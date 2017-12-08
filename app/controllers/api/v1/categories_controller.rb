class Api::V1::CategoriesController < Api::V1::BaseController
  before_action :staff_authentication, only: [:create, :destroy]
  def index
    render json: {categories: Category.all}
  end

  private
  def staff_authentication
    unless current_resource.staff?
      render json: {status: false, message: "Permission denied"}, status: 550
    end
  end
end