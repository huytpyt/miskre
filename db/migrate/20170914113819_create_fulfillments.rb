class CreateFulfillments < ActiveRecord::Migration[5.0]
  def change
    create_table :fulfillments do |t|
      t.references :order
      t.string :fulfillment_id
      t.string :status
      t.string :service
      t.string :tracking_company
      t.string :shipment_status
      t.string :tracking_number
      t.text :tracking_url

      t.timestamps
    end
  end
end
