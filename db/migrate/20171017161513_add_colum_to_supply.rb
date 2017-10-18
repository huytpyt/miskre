class AddColumToSupply < ActiveRecord::Migration[5.0]
  def change
    add_column :supplies, :epub, :float
    add_column :supplies, :dhl, :float
    add_column :supplies, :cost_epub, :float
    add_column :supplies, :cost_dhl, :float
    add_column :supplies, :compare_at_price, :float
  end
end
