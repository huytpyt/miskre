class CreateTableCustomer < ActiveRecord::Migration[5.0]
  def change
    create_table :customers do |t|
      t.string :shopify_order_id
      t.string :email, unique: true
      t.string :token
      t.string :fullname
      t.string :ship_address1
      t.string :ship_address2
      t.string :ship_city
      t.string :ship_state
      t.string :ship_zip
      t.string :ship_country
      t.string :ship_phone
      t.string :shipping_method
      t.string :country_code
      t.integer :total_quantity
      t.timestamps
    end
  end
end
