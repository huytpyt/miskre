class CreateUserNations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_nations do |t|
      t.text :code
      t.text :name
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
