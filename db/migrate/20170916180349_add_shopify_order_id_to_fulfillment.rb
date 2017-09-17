class AddShopifyOrderIdToFulfillment < ActiveRecord::Migration[5.0]
  def change
    add_column :fulfillments, :shopify_order_id, :string
  end
end
