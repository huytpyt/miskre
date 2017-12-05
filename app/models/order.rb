# == Schema Information
#
# Table name: orders
#
#  id                 :integer          not null, primary key
#  first_name         :string
#  last_name          :string
#  ship_address1      :string
#  ship_address2      :string
#  ship_city          :string
#  ship_state         :string
#  ship_zip           :string
#  ship_country       :string
#  ship_phone         :string
#  email              :string
#  quantity           :integer
#  skus               :text
#  unit_price         :text
#  date               :datetime
#  remark             :string
#  shipping_method    :string
#  tracking_no        :string
#  fulfill_fee        :float
#  product_name       :text
#  color              :string
#  size               :string
#  shop_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  shopify_id         :string
#  financial_status   :string
#  fulfillment_status :string
#  paid_for_miskre    :text
#  invoice_id         :integer
#
# Indexes
#
#  index_orders_on_shop_id     (shop_id)
#  index_orders_on_shopify_id  (shopify_id)
#
# Foreign Keys
#
#  orders_shop_id_fkey  (shop_id => shops.id)
#

class Order < ApplicationRecord
  belongs_to :shop

  has_many :line_items, dependent: :destroy
  has_many :products, through: :line_items
  has_many :fulfillments
  has_one :billings_order
  has_one :billing, through: :billings_orders
  belongs_to :invoices

  validates :shopify_id, uniqueness: true

  def self.search(search)
    if search
        where("lower(email) LIKE :search OR lower(first_name) LIKE :search
         OR lower(fulfillment_status) LIKE :search
         OR CAST(shopify_id AS TEXT) LIKE :search
         OR lower(last_name) LIKE :search OR lower(financial_status) LIKE :search", { search: "%#{search.downcase}%" })
    else
      scoped
    end
  end
end
