class Supply < ApplicationRecord
  belongs_to :shop
  belongs_to :product

  has_many :images, as: :imageable, dependent: :destroy
  after_initialize :copy_product_attr, :if => :new_record?

  def copy_product_attr
    self.name = self.product.name
    self.price = self.product.price
    self.desc = self.product.desc
    self.images = self.product.images
  end
end
