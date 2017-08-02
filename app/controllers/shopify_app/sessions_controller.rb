module ShopifyApp
  class SessionsController < ApplicationController
    include ShopifyApp::SessionsConcern

    protected

    def login_shop
      sess = ShopifyAPI::Session.new(shop_name, token)
      session[:shopify] = ::Shop.store_with_user(sess, current_user)
      session[:shopify_domain] = shop_name
    end
  end
end
