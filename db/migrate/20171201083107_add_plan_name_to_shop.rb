class AddPlanNameToShop < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :plan_name, :string
  end
end
