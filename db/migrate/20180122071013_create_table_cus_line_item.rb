class CreateTableCusLineItem < ActiveRecord::Migration[5.0]
  def change
    create_table :cus_line_items do |t|
      t.integer :customer_id
      t.string :sku
      t.integer :quantity
      t.string :shopify_line_item_id
      t.string :price
      t.string :title
      t.string :name
      t.boolean :on_system
      t.integer :shop_id
      t.timestamps
    end
  end
end
