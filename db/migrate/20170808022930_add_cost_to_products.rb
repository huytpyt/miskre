class AddCostToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :cost, :float
  end
end
