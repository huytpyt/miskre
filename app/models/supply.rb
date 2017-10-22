class Supply < ApplicationRecord
  belongs_to :shop
  belongs_to :product

  has_many :images, as: :imageable, dependent: :destroy
  has_many :supply_variants

  after_update :sync_this_supply
  before_destroy :remove_shopify_product

  def sync_this_supply
    JobsService.delay.sync_this_supply self.id
  end

  def copy_product_attr_add_product
    product = self.product
    shop = self.shop
    self.name = product&.name
    self.cost = User.find(self.user_id).user? ? product.cus_cost : product.cost
    self.price = product&.suggest_price
    self.desc = product&.desc
    self.compare_at_price = product&.compare_at_price
    self.epub = (1 - shop.shipping_rate)*product.cus_epub
    self.dhl = product.cus_dhl - shop.shipping_rate*product.cus_epub
    self.cost_epub = product.cus_epub
    self.cost_dhl = product.cus_dhl
  end

  def copy_product_attr
    product = self.product
    shop = self.shop
    self.name = product&.name
    self.cost = User.find(self.user_id).user? ? product.cus_cost : product.cost
    self.price = product&.suggest_price
    self.desc = product&.desc
    self.compare_at_price = product&.compare_at_price
    self.epub = (1 - shop.shipping_rate)*product.cus_epub
    self.dhl = product.cus_dhl - shop.shipping_rate*product.cus_epub
    self.cost_epub = product.cus_epub
    self.cost_dhl = product.cus_dhl
    self.supply_variants.destroy_all
    product.variants.each do |variant|
      self.supply_variants.create(option1: variant.option1, option2: variant.option2, option3: variant.option3, price: variant.price, sku: variant.sku, compare_at_price: variant.compare_at_price)
    end
    #only create or update at product

    # TODO sync images
    # self.images = product.images
  end

  def remove_shopify_product
    JobsService.remove_shopify_product self.shop.id, self.shopify_product_id
  end
end
