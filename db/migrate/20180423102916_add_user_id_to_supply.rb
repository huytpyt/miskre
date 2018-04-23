class AddUserIdToSupply < ActiveRecord::Migration[5.0]
  def change
    add_column :supplies, :user_id, :integer
  end
end
