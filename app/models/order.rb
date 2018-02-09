# == Schema Information
#
# Table name: orders
#
#  id                   :integer          not null, primary key
#  first_name           :string
#  last_name            :string
#  ship_address1        :string
#  ship_address2        :string
#  ship_city            :string
#  ship_state           :string
#  ship_zip             :string
#  ship_country         :string
#  ship_phone           :string
#  email                :string
#  quantity             :integer
#  skus                 :text
#  unit_price           :text
#  date                 :datetime
#  shipping_method      :string
#  tracking_no          :string
#  fulfill_fee          :float
#  product_name         :text
#  shop_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  shopify_id           :string
#  financial_status     :string
#  fulfillment_status   :string
#  invoice_id           :integer
#  request_charge_id    :integer
#  order_name           :string
#  country_code         :string
#  tracking_number_real :string
#  stock_warning        :string
#  pickup_info          :string
#  paid_for_miskre      :integer          default("none_paid")
#  products_cost        :decimal(, )
#  shipping_fee         :decimal(, )
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
  has_many :detail_invoices
  has_one :billings_order
  has_one :billing, through: :billings_orders
  belongs_to :invoices
  belongs_to :request_charge

  validates :shopify_id, uniqueness: true
  validates_numericality_of :shipping_fee, greater_than_or_equal_to: 0, if: -> { shipping_fee.present? }

  enum paid_for_miskre: %w(none_paid requesting charged_product pending accepted)

  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  def full_address
    if self.ship_address1.present? && self.ship_address2.present?
      "#{self.ship_address1} | #{self.ship_address2}"
    else
      "#{self.ship_address1} #{self.ship_address2}"
    end
  end

  def encode_token
    Base64.encode64(Customer.where(email: email).first.token)
  end

  def decode_token token
    Base64.decode64(token)
  end

  def is_order_owner? token
    token = decode_token(token)
    email == Customer.where(token: token).first.email
  end

  def products_in_order
    line_items.map{|item| {image: ProductService.find_image(item.sku), quantity: item.quantity, item_name: item.name}}
  end

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
