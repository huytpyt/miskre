class AddFieldsToLineItems < ActiveRecord::Migration[5.0]
  def change
    add_column :line_items, :price, :float
    add_column :line_items, :grams, :integer
    add_column :line_items, :title, :string
    add_column :line_items, :name, :string
    add_column :line_items, :variant_title, :string
  end
end
