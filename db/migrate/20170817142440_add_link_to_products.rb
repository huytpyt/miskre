class AddLinkToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :link, :text
  end
end
