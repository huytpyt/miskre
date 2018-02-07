class CreateInventoryVariant < ActiveRecord::Migration[5.0]
  def change
    create_table :inventory_variants do |t|
      t.integer :inventory_id
      t.integer :quantity
      t.integer :variant_id
      t.decimal :cost
      t.timestamps
    end
  end
end
