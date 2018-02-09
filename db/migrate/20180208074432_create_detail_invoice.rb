class CreateDetailInvoice < ActiveRecord::Migration[5.0]
  def change
    create_table :detail_invoices do |t|
      t.integer :invoice_id
      t.integer :order_id
      t.decimal :amount
      t.timestamps
    end
  end
end
