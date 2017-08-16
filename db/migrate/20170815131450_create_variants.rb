class CreateVariants < ActiveRecord::Migration[5.0]
  def change
    create_table :variants do |t|
      t.string :name
      t.string :option1
      t.string :option2
      t.string :option3
      t.integer :quantity
      t.float :price
      t.string :sku

      t.timestamps
      t.references :product, foreign_key: true
    end
  end
end
