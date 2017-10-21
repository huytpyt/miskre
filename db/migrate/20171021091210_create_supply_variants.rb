class CreateSupplyVariants < ActiveRecord::Migration[5.0]
  def change
    create_table :supply_variants do |t|
      t.string :option1
      t.string :option2
      t.string :option3
      t.float :price
      t.string :sku
      t.float :compare_at_price
      t.references :supply

      t.timestamps
    end
  end
end
