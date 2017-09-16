class AddUserToSupplies < ActiveRecord::Migration[5.0]
  def change
    add_reference :supplies, :user, foreign_key: true
  end
end
