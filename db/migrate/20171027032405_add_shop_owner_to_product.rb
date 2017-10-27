class AddShopOwnerToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :shop_owner, :boolean, default: false
  end
end
