class AddGlobalSettingEnableToShop < ActiveRecord::Migration[5.0]
  def change
    add_column :shops, :global_setting_enable, :boolean, default: false
  end
end
