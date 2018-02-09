class ChangeColumnPaidForMiskre < ActiveRecord::Migration[5.0]
  def up
    remove_column :orders, :paid_for_miskre, :boolean
    remove_column :orders, :remark, :string
    remove_column :orders, :color, :string
    remove_column :orders, :size, :string
    add_column :orders, :paid_for_miskre, :integer, default: 0
    add_column :orders, :products_cost, :decimal
  end

  def down
    remove_column :orders, :paid_for_miskre, :integer
    add_column :orders, :paid_for_miskre, :boolean
    add_column :orders, :remark, :string
    add_column :orders, :color, :string
    add_column :orders, :size, :string
    remove_column :orders, :products_cost, :decimal
  end
end
