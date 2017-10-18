class CarrierServiceController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :shipping_rates
  skip_before_action :authenticate_user!, only: :shipping_rates

  def index
    @shops = current_user.shops
  end

  def lookup
    country = params[:country]
    weight = params[:weight].to_i
    length = params[:length].to_i
    height = params[:height].to_i
    width = params[:width].to_i

    epub_cost = CarrierService.get_epub_cost(country, weight)

    cal_weight = (length * height * width) / 5
    weight = cal_weight > weight ? cal_weight : weight

    dhl_cost = CarrierService.get_dhl_cost(country, weight)

    data = {
      'epub': epub_cost.round(2),
      'dhl': dhl_cost.round(2)
    }
    respond_to do |format|
      format.json do
        render json: data
      end
      format.html { render status: 404 }
    end
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
    dhl_price = 0
    total_price = 0
    items.each do |i|
      product = Product.find_by_sku i['sku']
      cal_weight = (product.length * product.height * product.width) / 5
      weight = cal_weight > product.weight ? cal_weight : product.weight

      epub_us_cost = CarrierService.get_epub_cost('US', i['quantity'] * i['grams'])
      dhl_us_cost = CarrierService.get_dhl_cost('US', i['quantity'] * weight)

      epub_cost = CarrierService.get_epub_cost(country, i['quantity'] * i['grams'])
      diff_epub = epub_cost > epub_us_cost ? (epub_cost - epub_us_cost)*0.8 : 0
      dhl_cost = CarrierService.get_dhl_cost(country, i['quantity'] * weight)
      diff_dhl = dhl_cost > dhl_us_cost ? (dhl_cost - dhl_us_cost)*0.8 : 0

      epub_price += (0.2*epub_cost + diff_epub).round(2)
      dhl_price += (dhl_cost - 0.8*epub_us_cost + diff_dhl).round(2)
      # p i['quantity'], i['grams'], epub_price
      #
      total_price += i['quantity'] * i['price']
    end
    if total_price > 3500
      rates = [
        {
          # 'service_name': 'ePUB',
          'service_name': 'Free Insured Shipping',
          # 'description': '9-12 working days',
          # 'description': '8-12 days',
          'service_code': 'ePUP',
          'currency': 'USD',
          'total_price': 0
        },
        {
          # 'service_name': 'DHL',
          'service_name': 'DHL (not free)',
          # 'description': '5-8 working days',
          # 'description': '3-5 days',
          'service_code': 'DHL',
          'currency': 'USD',
          'total_price': (dhl_price * 100).round(0).to_s
        }
      ]
    else
      rates = [
        {
          # 'service_name': 'ePUB',
          'service_name': 'Insured Shipping',
          # 'description': '9-12 working days',
          # 'description': '8-12 days',
          'service_code': 'ePUP',
          'currency': 'USD',
          'total_price': (epub_price * 100).round(0).to_s
        },
        {
          # 'service_name': 'DHL',
          'service_name': 'Expedited Insured Shipping',
          # 'description': '5-8 working days',
          # 'description': '3-5 days',
          'service_code': 'DHL',
          'currency': 'USD',
          'total_price': (dhl_price * 100).round(0).to_s
        }
      ]
    end
    render :json => {"rates": rates}
  end
end
