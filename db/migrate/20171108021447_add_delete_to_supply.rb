class AddDeleteToSupply < ActiveRecord::Migration[5.0]
  def change
    add_column :supplies, :is_deleted, :boolean, default: false
  end
end
