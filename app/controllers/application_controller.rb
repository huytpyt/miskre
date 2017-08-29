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

  def after_sign_in_path_for(resource)
    if resource.instance_of?(User)
      return rails_admin_path if resource.admin?
      return root_path
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    # render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false

    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to main_app.root_url, :alert => exception.message }
    end
  end
end
