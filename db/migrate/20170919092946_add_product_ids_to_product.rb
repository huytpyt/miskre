class AddProductIdsToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :product_ids, :string
  end
end
