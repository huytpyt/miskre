class AddTableInvoice < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.integer :invoice_type
      t.string :user_id
      t.decimal :money_amount
      t.timestamps
    end
  end
end
