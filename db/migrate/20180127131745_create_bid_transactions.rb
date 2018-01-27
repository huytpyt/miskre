class CreateBidTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :bid_transactions do |t|
      t.integer :supplier_id
      t.integer :product_need_id
      t.decimal :cost
      t.date :time
      t.integer :status
      t.timestamps
    end
  end
end
