class ShopService
  def self.reset_carrier_service shop
    if shop.carrier_service_id.nil?
      result = activate_carrier_service shop
    else
      result = deactivate_carrier_service shop
    end
    result
  end

  def self.activate_carrier_service shop
    begin
      session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
      ShopifyAPI::Base.activate_session(session)
      ShopifyAPI::Shop.current
      carrier_service = ShopifyAPI::CarrierService.new
      carrier_service.name = "MiskreCarrier"
      carrier_service.callback_url = Rails.application.secrets.shipping_rates_url
      carrier_service.service_discovery = false
      carrier_service.save
      shop.update(carrier_service_id: carrier_service.id, use_carrier_service: true)
    rescue 
      "You need to add payment methods on shopify first!"
    end
  end

  def self.deactivate_carrier_service shop
    session = ShopifyAPI::Session.new(shop.shopify_domain, shop.shopify_token)
    ShopifyAPI::Base.activate_session(session)
    ShopifyAPI::Shop.current
    begin
      ShopifyAPI::CarrierService.delete(shop.carrier_service_id)
    rescue
      "You need to add payment methods on shopify first!"
    end
    shop.update(use_carrier_service: false, carrier_service_id: nil)
  end

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
    Supply.transaction do 
      shop.supplies.each do |supply|
        unless supply.keep_custom == true
          price = (supply.cost * shop.cost_rate + supply.cost_epub * shop.shipping_rate).round(2)
          random = rand(shop.random_from .. shop.random_to)
          compare_at_price = (price * random/ 5).round(0) * 5
          supply.supply_variants.each do |variant|
            variant.update(price: price, compare_at_price: compare_at_price)
          end
          supply.update(price: price, compare_at_price: compare_at_price)
        end
      end
    end
  end

  def self.update_price_suggest shop
    Supply.transaction do 
      shop.supplies.includes(:product).each do |supply|
        unless supply.keep_custom == true
          product = supply.product
          price = product.suggest_price
          random = rand(shop.random_from .. shop.random_to)
          compare_at_price = (price * random/ 5).round(0) * 5
          supply.supply_variants.each do |variant|
            variant.update(price: price, compare_at_price: compare_at_price)
          end
          supply.update(price: price, compare_at_price: compare_at_price)
        end
      end
    end
  end

  def self.update_supply shop
    Supply.transaction do 
      shop.supplies.includes(:product).each do |supply|
        unless supply.keep_custom == true
          product = supply.product
          random = rand(shop.random_from .. shop.random_to)
          supply.update(epub: (1 - shop.shipping_rate)*product.cus_epub)
          if shop.global_setting_enable == true
            price = (supply.cost * shop.cost_rate + supply.cost_epub * shop.shipping_rate).round(2)
            compare_at_price = (price * random/ 5).round(0) * 5
          else
            product = supply.product
            price = product.suggest_price
            compare_at_price = (price * random/ 5).round(0) * 5
          end
          supply.supply_variants.each do |variant|
            variant.update(price: price, compare_at_price: compare_at_price)
          end
          supply.update(price: price, compare_at_price: compare_at_price)
        end
      end
    end
  end
end