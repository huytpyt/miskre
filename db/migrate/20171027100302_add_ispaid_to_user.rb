class AddIspaidToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_paid, :boolean, default: false
    add_column :users, :period_end, :datetime
  end
end
