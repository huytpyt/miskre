class AddProductIdsToVariant < ActiveRecord::Migration[5.0]
  def change
    add_column :variants, :product_ids, :string
  end
end
