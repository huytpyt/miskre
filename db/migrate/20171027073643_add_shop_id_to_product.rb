class AddShopIdToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :shop_id, :integer
  end
end
