class AddChinaNameToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :china_name, :string
  end
end
