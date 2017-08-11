class AddCarrierServiceToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :use_carrier_service, :boolean
  end
end
