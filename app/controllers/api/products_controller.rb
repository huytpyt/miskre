class Api::ProductsController < ApplicationController
	before_action :prepare_nation, only: :profit_calculator

	def profit_calculator
		if @national
			us_shipping_type = @national.shipping_types.where(code: 'BEUS')&.first
			us_shipping_type ||= @national.shipping_types.first
			if us_shipping_type
				cost = params[:cost].to_f
				weight = params[:weight].to_f
				suggest_price = params[:suggest_price].to_f
				product_cus_epub = params[:product_cus_epub].to_f
				beus_cost = CarrierService.cal_cost(us_shipping_type, weight)
				if beus_cost
					diff_cost = beus_cost > product_cus_epub ? (beus_cost - product_cus_epub)*0.8 : 0
					beus_price = (0.2*beus_cost + diff_cost).round(2)
					total_cost = (cost + beus_cost).round(2)
					total_price = (suggest_price + beus_price).round(2)
					profit = (total_price - total_cost).round(2)
					json_response = {
						cost: cost, 
						weight: weight, 
						product_cus_epub: product_cus_epub,
						suggest_price: suggest_price,  
						beus_cost: beus_cost, 
						beus_price: beus_price,
						total_cost: total_cost, 
						total_price: total_price, 
						profit: profit
					}
					render json: {status: true, product: json_response}, status: 200
				else
					render json: {status: false, message: "Weight Not Valid!"}, status: 500
				end
			else
				render json: {status: false, message: "Shipping type unavailable!"}, status: 500
			end
		else
			render json: {status: false, message: "Nation unavailable!"}, status: 500
		end
	end

	private

		def prepare_nation
      @national = Nation.find_by_code('US')
      @national ||= Nation.first
    end

end
