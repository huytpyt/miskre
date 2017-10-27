class RemoveCusCompareAtPricefromProduct < ActiveRecord::Migration[5.0]
  def self.up
    remove_column :products, :cus_compare_at_price
    remove_column :products, :cus_price
  end

  def self.down
    add_column :products, :cus_compare_at_price, :float
    add_column :products, :cus_price, :float
  end

end
