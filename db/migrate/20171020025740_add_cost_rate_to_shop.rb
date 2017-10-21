class AddCostRateToShop < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :cost_rate, :float, default: 4
    add_column :shops, :shipping_rate, :float, default: 0.8
  end
end
