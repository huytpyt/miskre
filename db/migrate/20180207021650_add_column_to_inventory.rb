class AddColumnToInventory < ActiveRecord::Migration[5.0]
  def change
    add_column :inventories, :position, :string
  end
end
