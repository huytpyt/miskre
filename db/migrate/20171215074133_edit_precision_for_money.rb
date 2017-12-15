class EditPrecisionForMoney < ActiveRecord::Migration[5.0]
  def up
    change_column :balances, :total_amount, :numeric, :precision => 10, :scale => 2
    change_column :invoices, :money_amount, :numeric, :precision => 10, :scale => 2
  end

  def down
    change_column :balances, :total_amount, :decimal
    change_column :invoices, :money_amount, :decimal
  end
end
