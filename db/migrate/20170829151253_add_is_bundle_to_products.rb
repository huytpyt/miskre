class AddIsBundleToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :is_bundle, :boolean, default: false
  end
end
