class CreateShippingSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :shipping_settings do |t|
      t.references :user_shipping_type, foreign_key: true
      t.float :min_price
      t.text :max_price
      t.integer :percent
      t.text :packet_name

      t.timestamps
    end
  end
end
