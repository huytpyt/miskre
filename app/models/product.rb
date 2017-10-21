require 'elasticsearch/model'
class Product < ApplicationRecord
  include ShopifyApp::SessionStorage
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  Product.import(force: true)
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
  
  validates :name, presence: true, uniqueness: true
  validates :sku, presence: true, uniqueness: true
  validates :quantity, numericality: { only_integer: true}
  validates :cost, numericality: { greater_than_or_equal_to: 0}
  validates :weight, numericality: { only_integer: true,
                                       greater_than_or_equal_to: 0}

  after_initialize :generate_sku, :if => :new_record?
  # before_save :pack_bundle, if: :is_bundle
  before_save :calculate_price

  after_commit :sync_job
  serialize :product_ids

  def sync_job
    JobsService.delay.sync_product self.id
  end

  def pack_bundle
    unless self.products.empty?
      self.cost = 0
      self.weight = 0
      self.length = 0
      self.width = 0
      self.height = 0

      self.products.each do |p|
        self.cost += p.cost
        self.weight += p.weight
      end
    end
  end

  def calculate_price
    cal_weight = (self.length * self.height * self.width) / 5
    weight = cal_weight > self.weight ? cal_weight : self.weight

    epub_us_cost = CarrierService.get_epub_cost('US', self.weight)
    dhl_us_cost = CarrierService.get_dhl_cost('US', weight)

    self.cus_cost = (self.cost * 1.3).round(2)
    random = rand(2.25 .. 2.75)
    self.compare_at_price = (self.suggest_price * random/ 5).round(0) * 5
    
    self.epub = (0.2 * epub_us_cost).round(2)
    self.dhl = (dhl_us_cost - (1-0.2)*epub_us_cost).round(2)

    self.cus_epub = epub_us_cost
    self.cus_dhl = dhl_us_cost
  end

  def generate_sku
    p = Product.last
    if p
      last_sku_idx = SKU.index(p.sku)
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
        self.variants.create(sku: sku, option1: v, price: self.suggest_price, compare_at_price: self.compare_at_price)
      end
    when 2
      option1, option2 = self.options[0..1]
      option1.values.each do |v1|
        option2.values.each do |v2|
          sku = self.sku + self.variants.count().to_s.rjust(3, "0")
          self.variants.create(sku: sku, option1: v1, option2: v2,
                               price: self.suggest_price, compare_at_price: self.compare_at_price)
        end
      end
    when 3
      option1, option2, option3 = self.options[0..2]
      option1.values.each do |v1|
        option2.values.each do |v2|
          option3.values.each do |v3|
            sku = self.sku + self.variants.count().to_s.rjust(3, "0")
            self.variants.create(sku: sku, option1: v1, option2: v2,
                                 option3: v3, price: self.suggest_price, compare_at_price: self.compare_at_price)
          end
        end
      end
    end
  end
end
