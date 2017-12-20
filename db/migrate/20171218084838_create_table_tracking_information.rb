class CreateTableTrackingInformation < ActiveRecord::Migration[5.0]
  def change
    create_table :tracking_informations do |t|
      t.integer :fulfillment_id
      t.string :tracking_number
      t.integer :status, default: 0
      t.string :tracking_history
      t.timestamps
    end
  end
end
