class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :weight
      t.integer :length
      t.integer :height
      t.integer :width
      t.string :sku
      t.text :desc
      t.float :price
      t.float :compare_at_price

      t.timestamps
    end
  end
end
