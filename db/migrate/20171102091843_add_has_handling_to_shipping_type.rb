class AddHasHandlingToShippingType < ActiveRecord::Migration[5.0]
  def change
    add_column :shipping_types, :has_handling, :boolean, default: true
  end
end
