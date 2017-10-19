class OrdersSyncJob < ApplicationJob
  queue_as :default

  def perform
    ShopService.sync_orders
  end
end
