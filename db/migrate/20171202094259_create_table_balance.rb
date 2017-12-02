class CreateTableBalance < ActiveRecord::Migration[5.0]
  def change
    create_table :balances do |t|
      t.integer :user_id
      t.decimal :total_amount
      t.timestamps
    end
  end
end
