class AddFulfillableQuantityToLineItems < ActiveRecord::Migration[5.0]
  def change
    add_column :line_items, :fulfillable_quantity, :integer
    add_column :line_items, :fulfillment_status, :string
  end
end
