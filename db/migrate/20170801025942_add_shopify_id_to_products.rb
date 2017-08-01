class AddShopifyIdToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :shopify_id, :string
  end
end
