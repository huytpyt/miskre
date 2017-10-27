class Shop < ActiveRecord::Base
  include ShopifyApp::Shop
  include ShopifyApp::SessionStorage

  belongs_to :user

  has_many :supplies
  has_many :products, through: :supplies
  has_many :products
  has_many :orders

  validates :name, uniqueness: true

  before_create :get_shop_infor

  def self.store_with_user(session, current_user)
    shop = self.find_or_initialize_by(shopify_domain: session.url, user: current_user)
    shop.shopify_token = session.token
    shop.save!
    shop.id
  end

  def activate_carrier_service
    session = ShopifyAPI::Session.new(self.shopify_domain, self.shopify_token)
    ShopifyAPI::Base.activate_session(session)
    shop = ShopifyAPI::Shop.current

    unless self.carrier_service_id.nil?
      carrier_service = ShopifyAPI::CarrierService.find(self.carrier_service_id)
      carrier_service.active = true
      carrier_service.save
    else
      carrier_service = ShopifyAPI::CarrierService.new
      carrier_service.name = "Miskre"
      carrier_service.callback_url = Rails.application.secrets.shipping_rates_url
      carrier_service.service_discovery = false
      carrier_service.save
      self.update(carrier_service_id: carrier_service.id)
    end

    self.update(use_carrier_service: true)
  end

  def deactivate_carrier_service
    session = ShopifyAPI::Session.new(self.shopify_domain, self.shopify_token)
    ShopifyAPI::Base.activate_session(session)
    shop = ShopifyAPI::Shop.current
    carrier_service = ShopifyAPI::CarrierService.find(self.carrier_service_id)
    carrier_service.active = false
    carrier_service.save
    self.update(use_carrier_service: false)
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
