class CreateProductNeed < ActiveRecord::Migration[5.0]
  def change
    create_table :product_needs do |t|
      t.integer :product_id
      t.integer :variant_id
      t.integer :quantity
      t.integer :status
      t.timestamps
    end
  end
end
