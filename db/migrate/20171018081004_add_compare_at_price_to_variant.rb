class AddCompareAtPriceToVariant < ActiveRecord::Migration[5.0]
  def change
    add_column :variants, :compare_at_price, :float
  end
end
