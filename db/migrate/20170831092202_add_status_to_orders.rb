class AddStatusToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :financial_status, :string
    add_column :orders, :fulfillment_status, :string
  end
end
