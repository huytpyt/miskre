class AddPickUpInfoToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :pickup_info, :string
  end
end
