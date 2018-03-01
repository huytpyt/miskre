class AddPerchaseLinkToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :purchase_link, :text
  end
end
