class CreatePickupProductSheet < ActiveRecord::Migration[5.0]
  def change
    create_table :pickup_product_sheets do |t|
      t.string :file_name
      t.integer :status
      t.integer :user_id
      t.timestamps
    end
  end
end
