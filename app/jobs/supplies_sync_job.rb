class SuppliesSyncJob < ApplicationJob
  queue_as :default

  def perform(supply_id)
    # Do something later
    supply = Supply.find(supply_id)
    if supply
      c = ShopifyCommunicator.new(supply.shop_id)
      c.sync_product(supply_id)
    end
  end
end
