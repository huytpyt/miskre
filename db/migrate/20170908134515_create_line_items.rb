class CreateLineItems < ActiveRecord::Migration[5.0]
  def change
    create_table :line_items do |t|
      t.belongs_to :product, index: true
      t.belongs_to :order, index: true

      t.integer :quantity
      t.string :sku
      t.string :variant_id
      t.float :total_discount

      t.timestamps
    end
  end
end
