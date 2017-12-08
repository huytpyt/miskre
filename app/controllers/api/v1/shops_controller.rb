class Api::V1::ShopsController < Api::V1::BaseController
  before_action :check_shop, only: [:show, :destroy, :reload_plan_name]
  load_and_authorize_resource :shop
  before_action :prepare_nation, only: [:shipping] 

  def index
    render json: @shops.select(:id, :shopify_domain, :name, :domain, :plan_name)
  end

  def show
    supplies = @shop.supplies.where(is_deleted: false)

    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 12
    per_page = 12 if per_page.zero?
    total_page = supplies.size / per_page
    total_page = total_page <= 0 ? 1 : total_page

    render json: SuppliesQuery.list(page, per_page, params["search"], supplies, show_shop(@shop)), status: 200
  end

  def show_shop shop
    {id: shop.id, created_at: shop.created_at, updated_at: shop.updated_at, name: shop.name, domain: shop.domain, user_id: shop.user_id, cost_rate: shop.cost_rate, shipping_rate: shop.shipping_rate, random_from: shop.random_from, random_to: shop.random_to, global_setting_enable: shop.global_setting_enable, plan_name: shop.plan_name}
  end

  def shipping
    shop = Shop.find params[:shop_id]
    supply = Supply.find(params[:supply_id])
    product = supply.product
    weight = product.weight
    response = []
    @national.shipping_types.each do |shipping_type|
      shipping_cost = CarrierService.cal_cost(shipping_type, weight)
      if shipping_cost.nil?
        line = {code: shipping_type.code, data: "Weight Not Valid"}
      else
        diff_cost = shipping_cost  != supply.cost_epub ? (shipping_cost - supply.cost_epub)*shop.shipping_rate : 0
        shipping_price = ((1 - shop.shipping_rate)*shipping_cost + diff_cost).round(2)
        total_price = (supply.price + shipping_price).round(2)
        total_cost = (supply.cost + shipping_cost).round(2)
        line = {code: shipping_type.code, data: {cost: supply.cost, shipping_cost: shipping_cost, price: supply.price, shipping_price: shipping_price, total_cost: total_cost, total_price: total_price, profit: (total_price - total_cost).round(2)}}
      end
      response.push line
    end
    render json: {response: response}, status: 200
  end

  def update_global_price_setting
    shop = Shop.find(params[:shop_id])
    if shop.update(global_price_setting_params)
      ShopService.update_supply shop
      render json: {cost_rate: shop.cost_rate, shipping_rate: shop.shipping_rate, random_from: shop.random_from, random_to: shop.random_to}, status: 200
    else
      render json: {error: "Something went wrong!"}, status: 500
    end
  end

  def list_nations
    render json: {nations: Nation.all}, status: 200
  end

  def destroy
    @shop.destroy
    head :no_content
  end

  def change_price_option
    shop = Shop.find(params[:shop_id])
    if shop.global_setting_enable == true
      shop.global_setting_enable = false
      ShopService.update_price_suggest shop
    else
      shop.global_setting_enable = true
      ShopService.update_price_global_setting shop
    end
    if shop.save
      render json: {global_setting_enable: shop.global_setting_enable}, status: 200
    else
      render json: {error: "Something went wrong!"}, status: 500
    end
  end

  def reload_plan_name
    result = ShopService.update_plan_name @shop
    render json: {plan_name: result}, status: 200
  end

  private
  def prepare_nation
    @national = Nation.find_by_code(params[:nation] || 'US')
    @national ||= Nation.first
  end

  def global_price_setting_params
    params.permit(:cost_rate, :shipping_rate, :random_from, :random_to)
  end

  def check_shop
    unless Shop.find_by_id params[:id]
      render json: {error: "Not found"}, status: 404
    end
  end

end
