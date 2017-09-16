class AddSyncOptionToSupplies < ActiveRecord::Migration[5.0]
  def change
    add_column :supplies, :original, :boolean, default: true
  end
end
