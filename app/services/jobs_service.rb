class JobsService
  def self.fulfillment billing
    Shop.all.each do |shop|
      p shop.name
      begin
        communicator = ShopifyCommunicator.new(shop.id)
        communicator.sync_fulfillments(billing)
      rescue
        p "This shop already removed"
      end
    end
  end

  def self.add_product shop_id, product_id
    begin
      communicator = ShopifyCommunicator.new(shop_id)
      communicator.add_product(product_id)
    rescue
      p "This shop already removed"
    end
  end

  def self.sync_product product_id
    product = Product.find(product_id)
    product.supplies.where(original: true, is_deleted: false).where.not(shopify_product_id: nil).each do |s|
      s.copy_product_attr
      s.save
      sync_supply s.id
    end
  end

  def self.sync_supply supply_id
    supply = Supply.find_by_id(supply_id)
    if supply.present?
      begin
        c = ShopifyCommunicator.new(supply.shop_id)
        c.sync_product(supply_id)
      rescue
        p "This shop already removed"
      end
    end
  end

  def self.sync_this_supply supply_id
    supply = Supply.find_by_id(supply_id)
    if supply.present?
      begin
        c = ShopifyCommunicator.new(supply.shop_id)
        c.sync_supply(supply_id)
      rescue
        p "This shop already removed"
      end
    end
  end

  def self.remove_shopify_product shop_id, shopify_product_id
    begin
      c = ShopifyCommunicator.new(shop_id)
      c.remove_product(shopify_product_id)
    rescue
      p "This shop already removed"
    end
  end

  # def self.add_product_to_supplies shop_ids, product_id
  #   shop_ids.each do |id|
  #     c = ShopifyCommunicator.new(id)
  #     c.add_product(product_id)
  #   end
  # end
end