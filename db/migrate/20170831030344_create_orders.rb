class CreateOrders < ActiveRecord::Migration[5.0]
  def change
    create_table :orders do |t|
      t.string :first_name
      t.string :last_name
      t.string :ship_address1
      t.string :ship_address2
      t.string :ship_city
      t.string :ship_state
      t.string :ship_zip
      t.string :ship_country
      t.string :ship_phone
      t.string :email
      t.integer :quantity
      t.text :skus
      t.text :unit_price
      t.datetime :date
      t.string :remark
      t.string :shipping_method
      t.string :tracking_no
      t.float :fulfill_fee
      t.text :product_name
      t.string :color
      t.string :size
      t.references :shop, index: true, foreign_key: true

      t.timestamps
    end
  end
end
