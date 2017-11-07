class CarrierService
  def self.get_cost(country_code, weight, total_price, user_id)
    user_nation = UserNation.where(code: country_code, user_id: user_id).last
    unless user_nation.present?
      return []
    end
    user_shipping_types = user_nation.user_shipping_types.where(active: true)
    rates = []
    user_shipping_types.each do |user_shipping_type|
      shipping_type = user_shipping_type.shipping_type
      user_shipping_settings = user_shipping_type.shipping_settings.where("min_price < ?", total_price).last
      if shipping_type.has_handling
        detail = shipping_type.detail_shipping_types.where("weight_from <= ? AND ? <= weight_to", weight, weight).last
        total_original_cost = ((detail.cost * (weight.to_f/1000) + detail.handling_fee + 0.5)* 100).round(0).to_s if detail.present?
      else
        detail = shipping_type.detail_no_handlings.where("weight_from <= ? AND ? <= weight_to", weight, weight).last
        total_original_cost = ((detail.cost  + 0.5) * 100).round(0).to_s if detail.present?
      end
      if detail.present?
        item = {'service_name': user_shipping_settings.packet_name, 'service_code': shipping_type.code, 'currency': 'USD', 'total_price': total_original_cost} 
        rates.push(item)
      end
    end
    return rates
  end

  def self.cal_cost(shipping_type, weight)
    if shipping_type.has_handling
      detail = shipping_type.detail_shipping_types.where("weight_from <= ? AND ? <= weight_to", weight, weight).last
      total_original_cost = (detail.cost * (weight.to_f/1000) + detail.handling_fee + 0.5).round(2) if detail.present?
    else
      detail = shipping_type.detail_no_handlings.where("weight_from <= ? AND ? <= weight_to", weight, weight).last
      total_original_cost = (detail.cost + 0.5).round(2) if detail.present?
    end
    total_original_cost
  end
end
