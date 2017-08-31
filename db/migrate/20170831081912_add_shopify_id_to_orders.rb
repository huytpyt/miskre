class AddShopifyIdToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :shopify_id, :string, index: true
  end
end
