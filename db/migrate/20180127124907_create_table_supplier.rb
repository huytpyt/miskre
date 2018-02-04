class CreateTableSupplier < ActiveRecord::Migration[5.0]
  def change
    create_table :suppliers do |t|
      t.string :company_name
      t.string :address
      t.boolean :activate
      t.integer :user_id
      t.timestamps
    end
  end
end
