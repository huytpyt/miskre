class ShopService
  def self.sync_orders
    Shop.all.each do |shop|
      p shop.name
      communicator = ShopifyCommunicator.new(shop.id)
      communicator.sync_orders(60.days.ago, DateTime.now)
    end
  end

  def self.remove_all_products params
    shop = Shop.where(name: params[:name]).first
    if shop
      communicator = ShopifyCommunicator.new(shop.id)
      Product.order(sku: :asc).each do |product|
        p 'Remove product ' + product.name
        communicator.remove_product(product.id)
        sleep 0.5
      end
    else
      p 'Shop Not Found'
    end
  end

  def self.add_all_products params
    shop = Shop.where(name: params[:name]).first
    if shop
      communicator = ShopifyCommunicator.new(shop.id)
      Product.order(sku: :asc).each do |product|
        p 'Importing product ' + product.name
        communicator.add_product(product.id)
        sleep 0.5
      end
    else
      p 'Shop Not Found'
    end
  end
end