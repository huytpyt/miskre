class AddCusCompareAtPriceToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :cus_compare_at_price, :float
  end
end
