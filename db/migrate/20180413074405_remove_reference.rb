class RemoveReference < ActiveRecord::Migration[5.0]
  def change
    remove_reference :supplies, :user, foreign_key: true
  end
end
