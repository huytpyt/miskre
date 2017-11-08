class CreateUserShippingTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :user_shipping_types do |t|
      t.references :user_nation, foreign_key: true
      t.integer :shipping_type_id
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
