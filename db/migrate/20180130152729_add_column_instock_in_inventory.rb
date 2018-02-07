class AddColumnInstockInInventory < ActiveRecord::Migration[5.0]
  def change
    add_column :inventories, :in_stock, :integer
    add_column :inventory_variants, :in_stock, :integer
  end
end
