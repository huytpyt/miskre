class AddCountryCodeToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :country_code, :string
  end
end
