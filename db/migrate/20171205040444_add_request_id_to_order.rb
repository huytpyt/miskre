class AddRequestIdToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :request_charge_id, :integer
  end
end
