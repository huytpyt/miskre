class CarrierService
  def self.get_cost(country_code, weight, total_price, user_id, shop)
    user_nation = UserNation.where(code: country_code, user_id: user_id).last
    unless user_nation.present?
      return []
    end

    user_shipping_types = user_nation.user_shipping_types.where(active: true)
    rates = []
    user_shipping_types.each do |user_shipping_type|
      shipping_type = user_shipping_type.shipping_type
      user_shipping_settings = user_shipping_type.shipping_settings.where("min_price < ?", total_price).last
      percent = user_shipping_settings.percent
      if shipping_type.has_handling
        detail = shipping_type.detail_shipping_types.where("weight_from <= ? AND ? <= weight_to", weight, weight).last
        total_original_cost = ((detail.cost * (weight.to_f/1000) + detail.handling_fee + 0.5)* 100).round(0) if detail.present?
      else
        detail = shipping_type.detail_no_handlings.where("weight_from <= ? AND ? <= weight_to", weight, weight).last
        total_original_cost = ((detail.cost  + 0.5) * 100).round(0) if detail.present?
      end
      beus_type = Nation.find_by_code("US").shipping_types.find_by_code("BEUS")
      beus_cost = (cal_cost(beus_type, weight) * 100).round(0)
      diff_cost = total_original_cost  != beus_cost ? (total_original_cost - beus_cost)*shop.shipping_rate : 0
      shipping_price = (((1 - shop.shipping_rate)*total_original_cost + diff_cost)*(percent/100)).round(2).to_s
      if detail.present?
        item = {'service_name': user_shipping_settings.packet_name, 'service_code': shipping_type.code, 'currency': 'USD', 'total_price': shipping_price} 
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
