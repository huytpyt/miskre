class AddCostToSupply < ActiveRecord::Migration[5.0]
  def change
    add_column :supplies, :cost, :float
  end
end
