class CreateOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :options do |t|
      t.string :name
      t.string :values, array: true, default: []

      t.timestamps
      t.references :product, foreign_key: true
    end
  end
end
