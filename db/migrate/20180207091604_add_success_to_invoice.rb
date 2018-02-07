class AddSuccessToInvoice < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :success, :boolean, default: false
  end
end
