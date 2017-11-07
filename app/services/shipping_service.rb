class ShippingService
  def self.sync_shipping
    Nation.all.each do |nation|
      sync_this_nation nation
    end
  end

  def self.sync_this_nation nation
    nation.shipping_types.each do |shipping_type|
      User.where(role: "user").each do |user|
        user_nation = user.user_nations.find_by_code(nation.code) || user.user_nations.create(code: nation.code, name: nation.name)
        user_shipping_type = user_nation.user_shipping_types.find_by_shipping_type_id(shipping_type.id) || user_nation.user_shipping_types.create(shipping_type_id: shipping_type.id)
        user_shipping_type.shipping_settings.create(min_price: 0, max_price: "infinity", percent: 100, packet_name: "#{shipping_type.code} (#{shipping_type.time_range})") unless user_shipping_type.shipping_settings.present?
      end
    end
  end
end