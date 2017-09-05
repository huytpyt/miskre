class ProductsSyncJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    # Do something later
    supplies = Supply.where(product_id: product_id)
    supplies.each do |s|
      c = ShopifyCommunicator.new(s.shop_id)
      c.sync_product(product_id)
    end
  end
end
