class CreateRequestProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :request_products do |t|
      t.text :product_name
      t.string :link
      t.boolean :status, default: false
      t.references :user
      t.timestamps
    end
  end
end
