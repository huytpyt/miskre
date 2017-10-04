class AddFulfillableQuantityToSupply < ActiveRecord::Migration[5.0]
  def change
    add_column :supplies, :fulfillable_quantity, :integer
  end
end
