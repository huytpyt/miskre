class AddStockWarningToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :stock_warning, :string
  end
end
