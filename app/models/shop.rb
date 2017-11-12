# == Schema Information
#
# Table name: shops
#
#  id                    :integer          not null, primary key
#  shopify_domain        :string           not null
#  shopify_token         :string           not null
#  created_at            :datetime
#  updated_at            :datetime
#  name                  :string
#  domain                :string
#  user_id               :integer
#  use_carrier_service   :boolean
#  carrier_service_id    :string
#  cost_rate             :float            default(4.0)
#  shipping_rate         :float            default(0.8)
#  global_setting_enable :boolean          default(FALSE)
#  random_from           :float            default(2.25)
#  random_to             :float            default(2.75)
#
# Indexes
#
#  index_shops_on_shopify_domain  (shopify_domain) UNIQUE
#  index_shops_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Shop < ActiveRecord::Base
  include ShopifyApp::Shop
  include ShopifyApp::SessionStorage

  belongs_to :user

  has_many :supplies
  has_many :products, through: :supplies
  has_many :products
  has_many :orders
  has_many :user_products

  validates :name, uniqueness: true

  before_create :get_shop_infor

  def self.store_with_user(session, current_user)
    shop = self.find_or_initialize_by(shopify_domain: session.url, user: current_user)
    shop.shopify_token = session.token
    shop.save!
    shop.id
  end

  def activate_carrier_service
    ShopService.activate_carrier_service self
  end

  def deactivate_carrier_service
    ShopService.deactivate_carrier_service self
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
