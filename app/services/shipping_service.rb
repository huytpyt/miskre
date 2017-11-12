class ShippingService
  def self.sync_shipping
    Nation.all.each do |nation|
      sync_this_nation nation
    end
  end

  def self.sync_this_nation nation
    ceo = User.ceo
    if ceo
      admin_nation = ceo.user_nations.find_by_code(nation.code)
      User.where(role: "user").each do |user|
        admin_nation = ceo.user_nations.find_by_code(nation.code)
        user_nation = user.user_nations.find_by_code(nation.code)
        admin_nation.user_shipping_types.each do |shipping_type|
          user_shipping_type = user_nation.user_shipping_types.find_or_create_by!(shipping_type_id: shipping_type.shipping_type.id)
          if user_shipping_type
            user_shipping_type.update(active: shipping_type.active)
            admin_shipping_setting = shipping_type.shipping_settings
            user_shipping_type.shipping_settings.delete_all
            admin_shipping_setting.each do |shipping_setting|
              user_shipping_type.shipping_settings.create!(min_price: shipping_setting.min_price, max_price: shipping_setting.max_price, percent: shipping_setting.percent, packet_name: shipping_setting.packet_name)
            end
          end
        end
      end
    else
      nation.shipping_types.each do |shipping_type|
        User.where(role: "user").each do |user|
          user_nation = user.user_nations.find_by_code(nation.code) || user.user_nations.create(code: nation.code, name: nation.name)
          user_shipping_type = user_nation.user_shipping_types.find_by_shipping_type_id(shipping_type.id) || user_nation.user_shipping_types.create(shipping_type_id: shipping_type.id)
          user_shipping_type.shipping_settings.create(min_price: 0, max_price: "infinity", percent: 100, packet_name: "#{shipping_type.code} (#{shipping_type.time_range})") unless user_shipping_type.shipping_settings.present?
        end
      end
    end
  end

  def self.sync_shipping_for_user user
    default_shipping_setting(user)
  end

  def self.default_shipping_setting(user)
    ceo = User.ceo
    if ceo
      ceo.user_nations.each do |nation|
        user.user_nations.find_or_create_by!(code: nation.code, name: nation.name)
      end
      user.user_nations.each do |nation|
        admin_nation = ceo.user_nations.find_by_code(nation.code)
        admin_nation.user_shipping_types.each do |shipping_type|
          user_shipping_type = nation.user_shipping_types.find_or_create_by!(shipping_type_id: shipping_type.shipping_type.id)
          if user_shipping_type
            user_shipping_type.update(active: shipping_type.active)
            admin_shipping_setting = shipping_type.shipping_settings
            user_shipping_type.shipping_settings.delete_all
            admin_shipping_setting.each do |shipping_setting|
              user_shipping_type.shipping_settings.create!(min_price: shipping_setting.min_price, max_price: shipping_setting.max_price, percent: shipping_setting.percent, packet_name: shipping_setting.packet_name)
            end
          end
        end
      end
    else
      Nation.all.each do |nation|
        nation.shipping_types.each do |shipping_type|
          user_nation = user.user_nations.find_by_code(nation.code) || user.user_nations.create(code: nation.code, name: nation.name)
          user_shipping_type = user_nation.user_shipping_types.find_by_shipping_type_id(shipping_type.id) || user_nation.user_shipping_types.create(shipping_type_id: shipping_type.id)
          user_shipping_type.shipping_settings.create(min_price: 0, max_price: "infinity", percent: 100, packet_name: "#{shipping_type.code} (#{shipping_type.time_range})") unless user_shipping_type.shipping_settings.present?
        end
      end
    end
  end
end