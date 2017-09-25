class AddDefaultPriceToVariants < ActiveRecord::Migration[5.0]
  def change
    change_column :variants, :price, :float, default: 0
  end
end
