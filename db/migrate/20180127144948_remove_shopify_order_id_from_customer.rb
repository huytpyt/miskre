class RemoveShopifyOrderIdFromCustomer < ActiveRecord::Migration[5.0]
  def self.up
    remove_column :customers, :shopify_order_id
  end

  def self.down
    add_column :customers, :shopify_order_id, :string
  end
end
