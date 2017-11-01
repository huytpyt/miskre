class CreateImageRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :image_requests do |t|
      t.attachment :file
      t.references :request_product
      t.timestamps
    end
  end
end
