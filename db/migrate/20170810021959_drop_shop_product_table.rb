class DropShopProductTable < ActiveRecord::Migration[5.0]
  def change
    drop_table :products_shops
  end
end
