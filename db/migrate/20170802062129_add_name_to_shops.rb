class AddNameToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :name, :string
  end
end
