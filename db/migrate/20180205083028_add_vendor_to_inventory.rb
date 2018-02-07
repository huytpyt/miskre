class AddVendorToInventory < ActiveRecord::Migration[5.0]
  def change
    add_column :inventories, :vendor_id, :integer
  end
end
