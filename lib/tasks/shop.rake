# rake shop:add_all_products["xfanStore"]

namespace :shop do
  task :add_all_products, [:name] => :environment do |t, args|
    shop = Shop.where(name: args[:name]).first
    if shop
      c = ShopifyCommunicator.new(shop.id)
      Product.order(sku: :asc).each do |product|
        p 'Importing product ' + product.name
        c.add_product(product.id)
        sleep 0.5
      end
    else
      p 'Shop Not Found'
    end
  end

  task :remove_all_products, [:name] => :environment do |t, args|
    shop = Shop.where(name: args[:name]).first
    if shop
      c = ShopifyCommunicator.new(shop.id)
      Product.order(sku: :asc).each do |product|
        p 'Remove product ' + product.name
        c.remove_product(product.id)
        sleep 0.5
      end
    else
      p 'Shop Not Found'
    end
  end
end
