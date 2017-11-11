class AddFieldsToUserProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :user_products, :cost, :float, default: 0.0
    add_column :user_products, :suggest_price, :float, default:  0.0
  end
end
