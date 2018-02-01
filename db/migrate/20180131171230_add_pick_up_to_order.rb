class AddPickUpToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :pickup_product_sheet_id, :integer
  end
end
