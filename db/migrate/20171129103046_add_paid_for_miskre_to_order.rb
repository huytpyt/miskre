class AddPaidForMiskreToOrder < ActiveRecord::Migration[5.0]
  def up
    add_column :orders, :paid_for_miskre, :boolean, default: false
  end

  def down
    remove_column :orders, :paid_for_miskre, :boolean
  end
end
