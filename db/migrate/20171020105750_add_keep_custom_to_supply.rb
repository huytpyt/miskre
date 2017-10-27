class AddKeepCustomToSupply < ActiveRecord::Migration[5.0]
  def change
    add_column :supplies, :keep_custom, :boolean, default: false
  end
end
