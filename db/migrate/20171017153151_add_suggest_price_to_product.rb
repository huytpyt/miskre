class AddSuggestPriceToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :suggest_price, :float
  end
end
