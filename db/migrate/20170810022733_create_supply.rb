class CreateSupply < ActiveRecord::Migration[5.0]
  def change
    create_table :supplies do |t|
      t.belongs_to :product, index: true
      t.belongs_to :shop, index: true
      t.string :shopify_product_id
      t.timestamps
    end
  end
end
