class AddFbLinkToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :fb_link, :text
  end
end
