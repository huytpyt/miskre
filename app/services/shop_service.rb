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

  def self.update_price_global_setting shop
    shop.supplies.each do |supply|
      unless supply.keep_custom == true
        price = (supply.cost * shop.cost_rate + supply.cost_epub * shop.shipping_rate).round(2)
        random = rand(2.25 .. 2.75)
        compare_at_price = (price * random/ 5).round(0) * 5
        supply.supply_variants.each do |variant|
          variant.update(price: price, compare_at_price: compare_at_price)
        end
        supply.update(price: price, compare_at_price: compare_at_price)
      end
    end
  end

  def self.update_price_suggest shop
    shop.supplies.includes(:product).each do |supply|
      unless supply.keep_custom == true
        product = supply.product
        price = product.suggest_price
        compare_at_price = product.compare_at_price
        supply.supply_variants.each do |variant|
          variant.update(price: price, compare_at_price: compare_at_price)
        end
        supply.update(price: price, compare_at_price: compare_at_price)
      end
    end
  end

  def self.update_supply shop
    shop.supplies.includes(:product).each do |supply|
      unless supply.keep_custom == true
        product = supply.product
        supply.update(epub: (1 - shop.shipping_rate)*product.cus_epub, dhl: product.cus_dhl - shop.shipping_rate*product.cus_epub)
        if shop.global_setting_enable == true
          price = (supply.cost * shop.cost_rate + supply.cost_epub * shop.shipping_rate).round(2)
          random = rand(2.25 .. 2.75)
          compare_at_price = (price * random/ 5).round(0) * 5
        else
          product = supply.product
          price = product.suggest_price
          compare_at_price = product.compare_at_price
        end
        supply.supply_variants.each do |variant|
          variant.update(price: price, compare_at_price: compare_at_price)
        end
        supply.update(price: price, compare_at_price: compare_at_price)
      end
    end
  end
end