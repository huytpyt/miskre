class AddCusPriceToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :cus_price, :float, precision: 2, scale: 2
    add_column :products, :cus_cost, :float, precision: 2, scale: 2
  end
end
