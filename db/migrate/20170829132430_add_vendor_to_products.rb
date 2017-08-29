class AddVendorToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :vendor, :string, default: "Miskre"
  end
end
