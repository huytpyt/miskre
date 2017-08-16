class RemoveNameFromVariants < ActiveRecord::Migration[5.0]
  def change
    remove_column :variants, :name, :string
  end
end
