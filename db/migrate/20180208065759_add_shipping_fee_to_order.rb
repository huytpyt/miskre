class AddShippingFeeToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :shipping_fee, :decimal
  end
end
