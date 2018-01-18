class AddTrackingNumberRealToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :tracking_number_real, :string
  end
end
