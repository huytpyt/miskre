class AddUserToShop < ActiveRecord::Migration[5.0]
  def change
    add_reference :shops, :user, foreign_key: true
  end
end
