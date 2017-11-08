class Supply < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  Supply.import(force: true)
  
  belongs_to :shop
  belongs_to :product

  has_many :images, as: :imageable, dependent: :destroy
  has_many :supply_variants

  after_update :sync_this_supply

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0}
  validates :compare_at_price, presence: true, numericality: { greater_than_or_equal_to: 0}

  def sync_this_supply
    JobsService.delay.sync_this_supply self.id
  end

  def copy_product_attr_add_product
    product = self.product
    shop = self.shop
    self.name = product&.name
    self.cost = User.find(self.user_id).user? ? product.cus_cost : product.cost
    self.cost_epub = product.cus_epub
    self.cost_dhl = product.cus_dhl

    if shop.global_setting_enable == true
      self.price = (self.cost * shop.cost_rate + self.cost_epub * shop.shipping_rate).round(2)
    else
      self.price = product&.suggest_price
    end

    self.desc = product&.desc
    random = rand(shop.random_from .. shop.random_to)
    self.compare_at_price = (self.price * random/ 5).round(0) * 5
    self.epub = (1 - shop.shipping_rate)*product.cus_epub
    self.dhl = product.cus_dhl - shop.shipping_rate*product.cus_epub
  
  end

  def copy_product_attr
    product = self.product
    shop = self.shop
    self.name = product&.name
    self.cost = User.find(self.user_id).user? ? product.cus_cost : product.cost
    self.cost_epub = product.cus_epub
    self.cost_dhl = product.cus_dhl
    
    if shop.global_setting_enable == true
      self.price = (self.cost * shop.cost_rate + self.cost_epub * shop.shipping_rate).round(2)
    else
      self.price = product&.suggest_price
    end

    self.desc = product&.desc
    random = rand(shop.random_from .. shop.random_to)
    self.compare_at_price = (self.price * random/ 5).round(0) * 5
    self.epub = (1 - shop.shipping_rate)*product.cus_epub
    self.dhl = product.cus_dhl - shop.shipping_rate*product.cus_epub
    
    self.supply_variants.destroy_all
    product.variants.each do |variant|
      random = rand(shop.random_from .. shop.random_to)
      compare_at_price = (variant.price * random/ 5).round(0) * 5
      self.supply_variants.create(option1: variant.option1, option2: variant.option2, option3: variant.option3, price: variant.price, sku: variant.sku, compare_at_price: compare_at_price)
    end
    #only create or update at product

    # TODO sync images
    # self.images = product.images
  end
end
