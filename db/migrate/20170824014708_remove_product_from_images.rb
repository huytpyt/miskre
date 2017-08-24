class RemoveProductFromImages < ActiveRecord::Migration[5.0]
  def change
    remove_reference :images, :product, foreign_key: true
  end
end
