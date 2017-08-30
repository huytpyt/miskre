class SetDefaultValuesForProducts < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :weight, :integer, default: 0
    change_column :products, :length, :float, default: 0.0
    change_column :products, :height, :float, default: 0.0
    change_column :products, :width, :float, default: 0.0
    change_column :products, :price, :float, default: 0.0
    change_column :products, :cost, :float, default: 0.0
  end
end
