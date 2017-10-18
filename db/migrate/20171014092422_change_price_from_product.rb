class ChangePriceFromProduct < ActiveRecord::Migration[5.0]
  def self.up
    change_column :products, :cost, :float, precision: 2, scale: 2, default: nil
    change_column :products, :price, :float, precision: 2, scale: 2, default: nil
  end

  def self.down
    change_column :products, :cost, :float, default: 0.0
    change_column :products, :price, :float, default: 0.0
  end
end
