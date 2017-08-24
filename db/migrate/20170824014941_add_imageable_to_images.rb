class AddImageableToImages < ActiveRecord::Migration[5.0]
  def change
    add_reference :images, :imageable, polymorphic: true, index: true
  end
end
