class HomeController < ShopifyApp::AuthenticatedController
  def index
    @products = ShopifyAPI::Product.find(:all, :params => {:limit => 10})
  end

  def selectShop
    session[:shopify] = params[:shop_id]

    redirect_to action: :index
  end
end
