class CreateAccessTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :access_tokens do |t|

      t.string :scope
      t.string :access_token

      t.datetime :expires_at
      t.references :resource, null: false, polymorphic: true, index: true
      t.timestamps

    end

    add_index(:access_tokens, :access_token, unique: true)
  end
end
