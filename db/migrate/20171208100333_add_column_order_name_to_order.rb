class AddColumnOrderNameToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :order_name, :string
  end
end
