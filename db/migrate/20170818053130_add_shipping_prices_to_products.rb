class AddShippingPricesToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :epub, :float
    add_column :products, :dhl, :float
    remove_column :products, :shipping_price, :float
  end
end
