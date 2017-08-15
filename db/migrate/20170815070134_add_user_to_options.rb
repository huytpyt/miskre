class AddUserToOptions < ActiveRecord::Migration[5.0]
  def change
    add_reference :options, :user, foreign_key: true
  end
end
