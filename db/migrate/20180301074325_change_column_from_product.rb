class ChangeColumnFromProduct < ActiveRecord::Migration[5.0]
  def self.up
  	remove_column :products, :perchase_link
  	add_column :products, :purchase_link, :string
  end

  def self.down
  	add_column :products, :perchase_link, :string
  	remove_column :products, :purchase_link
  end
end
