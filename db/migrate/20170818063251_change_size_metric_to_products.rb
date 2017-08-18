class ChangeSizeMetricToProducts < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :length, :float
    change_column :products, :height, :float
    change_column :products, :width, :float
  end
end
