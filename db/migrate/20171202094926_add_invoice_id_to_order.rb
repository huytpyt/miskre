class AddInvoiceIdToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :invoice_id, :integer
  end
end
