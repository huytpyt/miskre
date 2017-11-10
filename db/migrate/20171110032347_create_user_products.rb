class CreateUserProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :user_products do |t|
    	t.string :name
      t.integer :weight
      t.integer :length
      t.integer :height
      t.integer :width
      t.string :sku
      t.text :desc
      t.float :price
      t.float :compare_at_price
      t.integer :quantity, default: 0
      t.string :shopify_product_id
      t.boolean :is_request, default: false, null: false
      t.string :status, default: ""

      t.references :user
      t.references :shop
      
      t.timestamps
    end
  end
end
