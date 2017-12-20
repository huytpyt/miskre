class AddCourierNameToTrackingInformation < ActiveRecord::Migration[5.0]
  def change
    add_column :tracking_informations, :courier_name, :string
  end
end
