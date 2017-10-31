class AddParentIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :parent_id, :integer
    add_column :users, :reference_code, :text
    add_column :users, :enable_ref, :boolean, default: false
    add_column :users, :name, :text
  end
end
