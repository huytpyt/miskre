class ProductsSyncJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    # Update product changes to supplies which set to be original
    # set supplies name, price, desc, images to be similar to product's
    product = Product.find(product_id)
    product.supplies.where(original: true).each do |s|
      s.copy_product_attr
      s.save
    end
  end
end
