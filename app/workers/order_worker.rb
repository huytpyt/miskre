class OrderWorker
  include Sidekiq::Worker

  # def perform(*args)
  def perform(shop_id)
    p shop_id
    # if Shop.find(shop_id)
    #   c = ShopifyCommunicator.new(shop_id)
    #   c.sync_order
    # end
  end
end
