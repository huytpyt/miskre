class AddApprovedToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :approved, :boolean, default: false
  end
end
