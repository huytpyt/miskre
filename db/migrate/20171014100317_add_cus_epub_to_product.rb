class AddCusEpubToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :cus_epub, :float, precision: 2, scale: 2
    add_column :products, :cus_dhl, :float, precision: 2, scale: 2
  end
end
