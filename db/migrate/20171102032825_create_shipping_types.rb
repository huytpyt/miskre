class CreateShippingTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :shipping_types do |t|
      t.text :code
      t.text :time_range
      t.references :nation
      t.timestamps
    end
  end
end
