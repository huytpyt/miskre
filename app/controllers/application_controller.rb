class ApplicationController < ActionController::Base
  include ShopifyApp::LoginProtection
  protect_from_forgery with: :exception
end
