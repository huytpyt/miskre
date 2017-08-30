class AddBundleToProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :products, :bundle, index: true
  end
end
