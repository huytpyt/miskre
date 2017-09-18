class FulfillmentsSyncJob < ApplicationJob
  queue_as :default

  def perform(billing_id)
    Shop.all.each do |shop|
      p shop.name
      communicator = ShopifyCommunicator.new(shop.id)
      communicator.sync_fulfillments(billing_id)
    end
  end
end
