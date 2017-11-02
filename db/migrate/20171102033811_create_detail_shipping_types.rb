class CreateDetailShippingTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :detail_shipping_types do |t|
      t.float :weight_from
      t.float :weight_to
      t.float :cost
      t.float :handling_fee
      t.references :shipping_type
      t.timestamps
    end
  end
end
