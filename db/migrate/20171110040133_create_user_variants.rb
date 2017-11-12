class CreateUserVariants < ActiveRecord::Migration[5.0]
  def change
    create_table :user_variants do |t|
    	t.string :name
      t.string :option1
      t.string :option2
      t.string :option3
      t.integer :quantity, default: 0
      t.float :price
      t.string :sku
      t.float :compare_at_price
      t.references :user_product, foreign_key: true
      
      t.timestamps
    end
  end
end
