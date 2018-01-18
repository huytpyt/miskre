class UpdateTrackingHistoy < ActiveRecord::Migration[5.0]
  def change
    TrackingInformation.destroy_all
    Fulfillment.all.each do |fulfillment|
      fulfillment.touch()
    end
  end
end
