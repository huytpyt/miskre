class AddIndexToOrders < ActiveRecord::Migration[5.0]
  def change
    add_index :orders, :shopify_id
  end
end
