class Api::V1::ProductListsController < Api::V1::BaseController
  before_action :authentication_user
  before_action :set_product, only: [:show, :add_to_shop_info, :assign_shop, :shipping]
  before_action :prepare_nation, only: [:shipping]
  before_action :set_shop, only: [:create_bundle, :new_bundle, :update_bundle]
  before_action :set_bundle_product, only: [:update_bundle, :regen_variants]
  def miskre_products
    staff_ids = User.where.not(role: "user").ids
    products = Product.all.where(shop_owner: false, approved: true, user_id: [staff_ids, nil])
    get_products params, products
  end

  def user_products
    products = current_resource.products.where(shop_owner: false, approved: true)
    get_products params, products
  end

  def show
    if (@product.user == [current_resource, nil]) || @product.user.staff?
      render json: ProductsQuery.single(@product), status: 200
    else
      render json: {status: false, message: "Permission denied"}, status: 550
    end
  end

  def add_to_shop_info
    available_shops = current_resource.shops - @product.shops
    supplies = @product.supplies.where(user_id: current_resource.id, is_deleted: false)
    shop_already_added = supplies.collect{|supply| supply&.shop}
    render json: {shop_can_add: available_shops, shop_already_added: shop_already_added}, status: 200
  end

  def assign_shop
    unless params[:shops].present?
      render json: {status: 500, error: "Params invalid"}, status: 500
      return
    end 
    shop_ids = params[:shops]
    shop_list = []
    available_shops = current_resource.shops - @product.shops
    unless shop_ids.empty?
      shop_ids.each do |id|
        shop = Shop.find_by_id id
        if available_shops.include? shop
          begin
            session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
            ShopifyAPI::Base.activate_session(session)
            ShopifyAPI::Shop.current
            JobsService.delay.add_product shop.id, @product.id
          rescue Exception => e
            notice = e.message
          end
        else
          notice = "This product already present on #{shop.name}"
        end
        shop_list.push({shop: shop, status: (notice.nil? ? 200 : 500), message: notice})
      end
      render json: {shop_list: shop_list}, status: 200
    else
      render json: {status: 404, error: "Not found shop to add"}, status: 404
    end
  end

  def shipping
    weight = @product.weight
    response = []
    @national.shipping_types.each do |shipping_type|
      shipping_cost = CarrierService.cal_cost(shipping_type, weight)
      if shipping_cost.nil?
        line = {code: shipping_type.code, data: "Weight Not Valid"}
      else
        diff_cost = shipping_cost  != @product.cus_epub ? (shipping_cost - @product.cus_epub)*0.8 : 0
        shipping_price = (0.2*shipping_cost + diff_cost).round(2)
        total_price = (@product.suggest_price + shipping_price).round(2)
        total_cost = (@product.cus_cost + shipping_cost).round(2)
        line = {code: shipping_type.code, data: {cost: @product.cus_cost, shipping_cost: shipping_cost, price: @product.suggest_price, shipping_price: shipping_price, total_cost: total_cost, total_price: total_price, profit: (total_price - total_cost).round(2)}}
      end
      response.push line
    end
    render json: {response: response}, status: 200
  end

  def new_bundle
    render json: ProductService.get_product_list(@shop), status: 200
  end

  def create_bundle
    if params[:product]
      product = current_resource.products.new(bundle_params)
      render json: ProductService.create_bundle(product, @shop, params)
    else
      render json: {status: false, error: "The params invalid!"}
    end
  end

  def regen_variants
    @product.regen_variants
    render :json => {status: true, variants: VariantsQuery.list(@product)}, status: 200
  end

  def update_bundle
    @product.attributes = bundle_params
    unless @product.user_id == current_user.id
      render json: {status: false, error: "You don't have permission"}
      return
    end
    if params[:product]
      render json: ProductService.update_bundle(@product, @shop, params)
    else
      render json: {status: false, error: "The params invalid!"}
    end
  end

  private
  def bundle_params
    params.require(:product).permit(:name, :desc, :sale_off)
  end

  def set_shop
    @shop = Shop.find_by_id(params[:shop_id])
    unless params[:shop_id].present? && @shop.present?
      render json: {error: "Shop id required"}, status: 500
      return
    end
  end

  def set_bundle_product
    @product = Product.find(params[:product_id])
    unless @product.present?
      render json: {status: false, error: "This product not found"}
      return
    end
    unless @product.user_id == current_user.id
      render json: {status: false, error: "You don't have permission"}
      return
    end
  end

  def authentication_user
    unless current_resource.user?
      render json: {status: false, message: "Permission denied, for user only"}, status: 550
      return
    end
  end

  def prepare_nation
    @national = Nation.find_by_code(params[:nation] || 'US')
    @national ||= Nation.first
  end

  def set_product
    @product = Product.where(approved: true).find_by_id(params[:id] || params[:product_list_id])
    if @product.nil?
      render json: {status: false, error: "Not found!"}, status: 404
      return
    end
  end
  def get_products params, products
    page = params[:page].to_i || 1
    page = 1 if page.zero?
    per_page = params[:per_page].to_i || 20
    per_page = 20 if per_page.zero?
    sort = params[:sort] || 'DESC'
    order_by = params[:order_by] || 'id'
    search = params[:q]
    render json: ProductsQuery.list_miskre(products, page, per_page, sort, order_by, search), status: 200
  end
end