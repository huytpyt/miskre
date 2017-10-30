class CreateShippings < ActiveRecord::Migration[5.0]
  def change
    create_table :shippings do |t|
      t.references :user
      t.float :min_price
      t.text :max_price
      t.integer :percent_dhl
      t.integer :percent_epub
      t.text :name_dhl
      t.text :name_epub

      t.timestamps
    end
  end
end
