class CarrierServiceController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :shipping_rates
  skip_before_action :authenticate_user!, only: :shipping_rates

  def index
    @shops = current_user.shops
  end

  def activate
    @shop = Shop.find(params[:shop_id])
    @shop.activate_carrier_service

    redirect_to carrier_service_url, notice: 'Service was activated.' 
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
    items.each do |i|
      epub_price += CarrierService.get_epub_price(country, i['quantity'] * i['grams'])
    end

    rates = []
    rates[0] = {
      'service_name': 'ePUB', 
      'description': '9-12 working days',
      'service_code': 'ePacket',
      'currency': 'USD',
      'total_price': epub_price
    }
    
    render :json => {"rates": rates}
  end
end
