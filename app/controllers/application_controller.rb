class ApplicationController < ActionController::Base
  include ShopifyApp::LoginProtection
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_current_shop

  def set_current_shop
    if user_signed_in?
      unless current_user.shops.empty?
        session[:shopify] ||= current_user.shops.first.id
      end
    end
  end
end
