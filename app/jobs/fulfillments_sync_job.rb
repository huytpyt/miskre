class FulfillmentsSyncJob < ApplicationJob
  queue_as :default

  def perform()
    Shop.all.each do |shop|
      p shop.name
      communicator = ShopifyCommunicator.new(shop.id)
      communicator.sync_fulfillments(shop)
    end
  end
end
