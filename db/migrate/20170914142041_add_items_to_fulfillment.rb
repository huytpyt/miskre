class AddItemsToFulfillment < ActiveRecord::Migration[5.0]
  def change
    add_column :fulfillments, :items, :string
  end
end
