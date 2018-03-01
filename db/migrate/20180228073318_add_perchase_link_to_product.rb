class AddPerchaseLinkToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :perchase_link, :text
  end
end
