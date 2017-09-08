class Product < ApplicationRecord
  include ShopifyApp::SessionStorage

  # has_many :images, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy

  has_many :supplies
  has_many :shops, through: :supplies
  has_many :options, dependent: :destroy
  has_many :variants, dependent: :destroy

  has_many :products, class_name: "Product", foreign_key: "bundle_id"
  belongs_to :bundle, class_name: "Product"

  has_many :line_items
  has_many :orders, through: :line_items

  validates :name, presence: true

  before_create :generate_sku
  # after_create :calculate_price
  before_save :pack_bundle, if: :is_bundle
  before_save :calculate_price

  after_save :sync_job

  def sync_job
    ProductsSyncJob.perform_later(self.id)
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
    epub_us_cost = CarrierService.get_epub_cost('US', self.weight)
    dhl_us_cost = CarrierService.get_dhl_cost('US', weight)

    self.price = (self.cost * 3 + epub_us_cost * 0.8).round(0)
    # patch is the portion of shipping_cost which is added to product price
    patch = (self.price - self.cost * 3).round(2)
    self.epub = (epub_us_cost - patch).round(2)
    self.dhl = (dhl_us_cost - patch).round(2)
    # self.save
  end

  def generate_sku
    self.sku = SKU[Product.count]
    # self.sku = space[p1] + space[p2] + space[p3]
  end

  def regen_variants
    self.variants.clear
    case self.options.count
    when 1
      option1 = self.options.first
      option1.values.each do |v|
        sku = self.sku + self.variants.count().to_s.rjust(3, "0")
        self.variants.create(sku: sku, option1: v)
      end
    when 2
      option1, option2 = self.options[0..1]
      option1.values.each do |v1|
        option2.values.each do |v2|
          sku = self.sku + self.variants.count().to_s.rjust(3, "0")
          self.variants.create(sku: sku, option1: v1, option2: v2)
        end
      end
    when 3
      option1, option2, option3 = self.options[0..2]
      option1.values.each do |v1|
        option2.values.each do |v2|
          option3.values.each do |v3|
            sku = self.sku + self.variants.count().to_s.rjust(3, "0")
            self.variants.create(sku: sku, option1: v1, option2: v2, option3: v3)
          end
        end
      end
    end
  end
end
