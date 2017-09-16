class Supply < ApplicationRecord
  belongs_to :shop
  belongs_to :product

  has_many :images, as: :imageable, dependent: :destroy
  after_initialize :copy_product_attr, :if => :new_record?
  after_save :sync_job, :unless => :new_record?
  before_destroy :remove_shopify_product

  def sync_job
    SuppliesSyncJob.perform_later(self.id)
  end

  def copy_product_attr
    self.name = self.product.name
    self.price = self.product.price
    self.desc = self.product.desc
    self.images = self.product.images
  end

  def remove_shopify_product
    c = ShopifyCommunicator.new(self.shop.id)
    c.remove_product(self.shopify_product_id)
  end
end
