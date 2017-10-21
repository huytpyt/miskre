class Supply < ApplicationRecord
  belongs_to :shop
  belongs_to :product

  has_many :images, as: :imageable, dependent: :destroy
  after_initialize :copy_product_attr, :if => :new_record?
  # after_save :sync_job, :unless => :new_record?
  after_save :sync_job
  before_destroy :remove_shopify_product
  def sync_job
    JobsService.delay.sync_supply self.id
    # c = ShopifyCommunicator.new(self.shop_id)
    # c.sync_product(self.id)
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
    # TODO sync images
    # self.images = product.images
  end

  def remove_shopify_product
    JobsService.delay.remove_shopify_product self.shop.id, self.shopify_product_id
  end
end
