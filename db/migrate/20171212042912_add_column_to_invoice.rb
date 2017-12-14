class AddColumnToInvoice < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :balance, :decimal
    add_column :invoices, :memo, :string
  end
end
