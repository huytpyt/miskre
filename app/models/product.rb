class Product < ApplicationRecord
  include ShopifyApp::SessionStorage

  # after_create :shopify_create
  # after_update :shopify_update
  # after_destroy :shopify_destroy

  has_many :images, dependent: :destroy

  def shopify_create
    new_product = ShopifyAPI::Product.new
    new_product.title = self.name
    new_product.save
    self.update(shopify_id: new_product.id)
  end

  def shopify_update
    product = ShopifyAPI::Product.find(self.shopify_id)
    product.title = self.name
    product.save
  end

  def shopify_destroy
    product = ShopifyAPI::Product.find(self.shopify_id)
    product.destroy
  end
end
