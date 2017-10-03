class CreateTrackingProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :tracking_products do |t|
      t.integer :open
      t.integer :high
      t.integer :low
      t.integer :close
      t.references :product, index: true
      t.timestamps
    end
  end
end
