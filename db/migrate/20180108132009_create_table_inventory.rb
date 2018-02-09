class CreateTableInventory < ActiveRecord::Migration[5.0]
  def change
    create_table :inventories do |t|
      t.integer :product_id
      t.integer :quantity
      t.decimal :cost
      t.timestamps
    end
  end
end
