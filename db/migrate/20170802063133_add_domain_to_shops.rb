class AddDomainToShops < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :domain, :string
  end
end
