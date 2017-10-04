class AddFulfillableQuantityToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :fulfillable_quantity, :integer
  end
end
