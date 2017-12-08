class CreateResourceImages < ActiveRecord::Migration[5.0]
  def change
    create_table :resource_images do |t|
      t.attachment :file
      t.references :product
      t.timestamps
    end
  end
end
