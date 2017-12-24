require 'sidekiq-scheduler'

class SyncOrder
  include Sidekiq::Worker

  def perform
    ShopService.sync_orders()
  end

end
