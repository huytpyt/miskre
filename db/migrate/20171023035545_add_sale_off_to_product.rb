class AddSaleOffToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :sale_off, :integer
  end
end
