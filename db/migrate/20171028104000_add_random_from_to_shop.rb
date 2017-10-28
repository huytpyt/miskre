class AddRandomFromToShop < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :random_from, :float, default: 2.25
    add_column :shops, :random_to, :float, default: 2.75
  end
end
