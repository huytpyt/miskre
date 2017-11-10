# == Schema Information
#
# Table name: products
#
#  id                   :integer          not null, primary key
#  name                 :string
#  weight               :integer          default(0)
#  length               :float            default(0.0)
#  height               :float            default(0.0)
#  width                :float            default(0.0)
#  sku                  :string
#  desc                 :text
#  price                :float
#  compare_at_price     :float
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  shopify_id           :string
#  cost                 :float
#  link                 :text
#  epub                 :float
#  dhl                  :float
#  vendor               :string           default("Miskre")
#  bundle_id            :integer
#  is_bundle            :boolean          default(FALSE)
#  quantity             :integer          default(0)
#  product_ids          :string
#  user_id              :integer
#  product_url          :string
#  fulfillable_quantity :integer
#  cus_cost             :float
#  cus_epub             :float
#  cus_dhl              :float
#  suggest_price        :float
#  sale_off             :integer
#  shop_owner           :boolean          default(FALSE)
#  shop_id              :integer
#
# Indexes
#
#  index_products_on_bundle_id  (bundle_id)
#  index_products_on_user_id    (user_id)
#

require 'elasticsearch/model'
class Product < ApplicationRecord
  include ShopifyApp::SessionStorage
  # has_many :images, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy

  has_many :supplies
  has_many :shops, through: :supplies
  has_many :options, dependent: :destroy
  has_many :variants, dependent: :destroy

  # has_many :products, class_name: "Product", foreign_key: "bundle_id"
  # belongs_to :bundle, class_name: "Product"

  has_many :line_items
  has_many :orders, through: :line_items
  belongs_to :user
  has_many :tracking_products
  belongs_to :shop
  
  validates :suggest_price, presence: true, numericality: { greater_than_or_equal_to: 0}
  validates :name, presence: true, uniqueness: true
  validates :product_url, url: {allow_blank: true}
  validates :sku, presence: true, uniqueness: true
  validates :quantity, numericality: { only_integer: true}
  validates :cost, numericality: { greater_than_or_equal_to: 0}
  validates :weight, presence: true, numericality: { only_integer: true,
                                       greater_than_or_equal_to: 1}
  validates :length, numericality: true
  validates :height, numericality: true
  validates :width, numericality: true

  after_initialize :generate_sku, :if => :new_record?
  # before_save :pack_bundle, if: :is_bundle
  before_save :calculate_price

  after_commit :sync_job
  serialize :product_ids

  validate :validate_bundle

  def validate_bundle
    if self.is_bundle
      if self.product_ids == []
        errors.add(:product_ids, "is required")
      end
    end
  end

  def sync_job
    JobsService.delay.sync_product self.id
  end

  def calculate_price
    # cal_weight = (self.length * self.height * self.width) / 5
    # weight = cal_weight > self.weight ? cal_weight : self.weight

    us_nation = Nation.find_by_code "US"
    shipping_type = us_nation.shipping_types.find_by_code "BEUS"
    weight = self.weight
    if self.weight < 10
      weight = 10
    end
    if self.weight > 4000
      weight = 4000
    end
    beus_us_cost = CarrierService.cal_cost(shipping_type, weight).to_f
    # dhl_us_cost = CarrierService.get_dhl_cost('US', weight)
    self.cus_cost = self.cost >= 5 ? (self.cost + 1.5).round(2) : (self.cost*30/ 100).round(2)
    random = rand(2.25 .. 2.75)
    if self.compare_at_price.nil?
      self.compare_at_price = (self.suggest_price * random/ 5).round(0) * 5
    end
    
    self.epub = (0.2 * beus_us_cost).round(2)
    # self.dhl = (dhl_us_cost - (1-0.2)*epub_us_cost).round(2)

    self.cus_epub = beus_us_cost
    # self.cus_dhl = dhl_us_cost

    self.price = self.cost*4 + 0.8*self.cus_epub
  end

  def generate_sku
    return if self.sku.present?
    p = Product.last
    if p
      last_sku_idx = SKU.index(p.sku)
      if last_sku_idx.nil?
        last_sku_idx = -1
      end
    else
      last_sku_idx = -1
    end

    idx = last_sku_idx + 1
    while Product.find_by(sku: SKU[idx]) do
      idx += 1
    end
    self.sku = SKU[idx]
  end

  def regen_variants
    self.variants.clear
    case self.options.count
    when 1
      option1 = self.options.first
      option1.values.each do |v|
        sku = self.sku + self.variants.count().to_s.rjust(3, "0")
        self.variants.create(sku: sku, option1: v, price: self.suggest_price, compare_at_price: self.compare_at_price, product_ids: self.product_ids)
      end
    when 2
      option1, option2 = self.options[0..1]
      option1.values.each do |v1|
        option2.values.each do |v2|
          sku = self.sku + self.variants.count().to_s.rjust(3, "0")
          self.variants.create(sku: sku, option1: v1, option2: v2,
                               price: self.suggest_price, compare_at_price: self.compare_at_price, product_ids: self.product_ids)
        end
      end
    when 3
      option1, option2, option3 = self.options[0..2]
      option1.values.each do |v1|
        option2.values.each do |v2|
          option3.values.each do |v3|
            sku = self.sku + self.variants.count().to_s.rjust(3, "0")
            self.variants.create(sku: sku, option1: v1, option2: v2,
                                 option3: v3, price: self.suggest_price, compare_at_price: self.compare_at_price, product_ids: self.product_ids)
          end
        end
      end
    end
  end
end
