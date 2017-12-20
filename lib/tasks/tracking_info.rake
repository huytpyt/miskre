namespace :tracking_info do
  desc "Create tracking information for old fulfillment"
  task create_tracking_info: :environment do
    Fulfillment.all.each do |f|
      f.touch
    end
    p "========DONE=========="
  end

end
