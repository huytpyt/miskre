class CarrierServiceController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :shipping_rates
  skip_before_action :authenticate_user!, only: :shipping_rates

  def index
    @shops = current_user.staff? ? Shop.all : current_user.shops
  end

  def lookup
    country = params[:country]
    @weight = params[:weight].to_i
    @shipping_types = Nation.find_by_code(country).shipping_types
    render :layout => false
  end

  def activate
    @shop = Shop.find(params[:shop_id])
    success = @shop.activate_carrier_service
    if success == true
      notice = 'Service was activated.' 
    else
      notice = success
    end
    redirect_to carrier_service_url, notice: notice
  end

  def deactivate
    @shop = Shop.find(params[:shop_id])
    @shop.deactivate_carrier_service

    redirect_to carrier_service_url, notice: 'Service was deactivated.' 
  end

  def shipping_rates
    rate = params[:rate]
    country = rate['destination']['country']
    items = rate['items']
    epub_price = 0
    dhl_price = 0
    total_price = 0
    total_grams = 0
    vendor = ""
    items.each do |i|
      # product = Product.find_by_sku i['sku']&.first(3)
      # cal_weight = (product.length * product.height * product.width) / 5
      # weight = cal_weight > product.weight ? cal_weight : product.weight

      

      # epub_cost = CarrierService.get_epub_cost(country, i['quantity'] * i['grams'])
      # diff_epub = epub_cost > epub_us_cost ? (epub_cost - epub_us_cost)*0.8 : 0
      # dhl_cost = CarrierService.get_dhl_cost(country, i['quantity'] * weight)
      # diff_dhl = dhl_cost > dhl_us_cost ? (dhl_cost - dhl_us_cost)*0.8 : 0

      # epub_price += (0.2*epub_cost + diff_epub).round(2)
      # dhl_price += (dhl_cost - 0.8*epub_us_cost + diff_dhl).round(2)
      # p i['quantity'], i['grams'], epub_price
      #
      total_price += i['quantity'] * i['price']
      total_grams += i['quantity'] * i['grams']
      vendor = i['vendor']
    end
    shop = Shop.find_by_shopify_domain(vendor)
    user_id = shop&.user&.id
    shipping_cost = []
    shipping_cost = CarrierService.get_cost(country, total_grams, (total_price.to_f)/100, user_id, shop) if user_id.present?
    render :json => {"rates": shipping_cost}
  end
end
