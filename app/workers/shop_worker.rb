require 'sidekiq-scheduler'

class ShopWorker
  include Sidekiq::Worker

  def perform(*args)
    ShopService.delay.sync_orders
  end
end
