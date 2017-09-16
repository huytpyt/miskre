class AddInforToSupplies < ActiveRecord::Migration[5.0]
  def change
    add_column :supplies, :desc, :text
    add_column :supplies, :price, :float
    add_column :supplies, :name, :string
  end
end
