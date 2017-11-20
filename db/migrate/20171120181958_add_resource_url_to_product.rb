class AddResourceUrlToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :resource_url, :string
    add_column :products, :vendor_detail, :text
    add_column :products, :cost_per_quantity, :string
  end
end
