class CreateDetailNoHandlings < ActiveRecord::Migration[5.0]
  def change
    create_table :detail_no_handlings do |t|
      t.integer :weight_from
      t.integer :weight_to
      t.float :cost
      t.references :shipping_type
      t.timestamps
    end
  end
end
