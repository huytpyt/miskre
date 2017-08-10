class Shop < ActiveRecord::Base
  include ShopifyApp::Shop
  include ShopifyApp::SessionStorage

  belongs_to :user

  has_many :supplies
  has_many :products, through: :supplies

  before_create :get_shop_infor

  def self.store_with_user(session, current_user)
    shop = self.find_or_initialize_by(shopify_domain: session.url, user: current_user)
    shop.shopify_token = session.token
    shop.save!
    shop.id
  end

  private
  def get_shop_infor
    session = ShopifyAPI::Session.new(self.shopify_domain, self.shopify_token)
    ShopifyAPI::Base.activate_session(session)
    shop = ShopifyAPI::Shop.current
    self.name = shop.name
    self.domain = shop.domain
  end
end
