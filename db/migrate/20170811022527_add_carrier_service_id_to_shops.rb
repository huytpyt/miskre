class AddCarrierServiceIdToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :carrier_service_id, :string
  end
end
