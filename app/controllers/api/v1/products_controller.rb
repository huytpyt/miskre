class Api::V1::ProductsController < Api::V1::BaseController
  def index
  	page = params[:page].to_i || 1
  	page = 1 if page.zero?
  	per_page = params[:per_page].to_i || 20
  	per_page = 20 if per_page.zero?
  	total_page = Product.count / per_page
  	total_page = total_page <= 0 ? 1 : total_page
  	sort = params[:sort] || 'DESC' 
  	render json: ProductsQuery.list(page, per_page, sort), status: 200
  end

  def show
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  	def get_next_page(total_page, current_page)
  		return if total_page <= 1
  		if current_page > 1 && current_page < total_page
  			current_page + 1
  		end
  	end

  	def get_prev_page(total_page, current_page)
  		return if total_page <= 1
  		if current_page > 1 && current_page <= total_page
  			current_page -1
  		end
  	end
end
