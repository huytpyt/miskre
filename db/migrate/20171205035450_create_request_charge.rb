class CreateRequestCharge < ActiveRecord::Migration[5.0]
  def change
    create_table :request_charges do |t|
      t.integer :user_id
      t.decimal :total_amount
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
