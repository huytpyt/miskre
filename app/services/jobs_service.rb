class JobsService
  def self.fulfillment billing_id
    Shop.all.each do |shop|
      p shop.name
      communicator = ShopifyCommunicator.new(shop.id)
      communicator.sync_fulfillments(billing_id)
    end
  end

  def self.sync_product product_id
    product = Product.find(product_id)
    product.supplies.where(original: true).each do |s|
      s.copy_product_attr
      s.save
    end
  end

  def self.sync_supply supply_id
    supply = Supply.find_by_id(supply_id)
    if supply.present?
      c = ShopifyCommunicator.new(supply.shop_id)
      c.sync_product(supply_id)
    end
  end

  def self.sync_this_supply supply_id
    supply = Supply.find_by_id(supply_id)
    if supply.present?
      c = ShopifyCommunicator.new(supply.shop_id)
      c.sync_supply(supply_id)
    end
  end

  def self.remove_shopify_product shop_id, shopify_product_id
    c = ShopifyCommunicator.new(shop_id)
    c.remove_product(shopify_product_id)
  end

  # def self.add_product_to_supplies shop_ids, product_id
  #   shop_ids.each do |id|
  #     c = ShopifyCommunicator.new(id)
  #     c.add_product(product_id)
  #   end
  # end
end