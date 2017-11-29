class VariantService
  def self.update_variant product, variant
    random = rand(2.25 .. 2.75)
    if product.is_bundle
      total_weight = 0
      total_cost = 0
      total_price = 0
      variant.product_ids.each do |id|
        p = Product.find(id[:product_id])
        weight = p.weight
        length = p.length
        height = p.height
        width = p.width
        cal_weight = (length * height * width) / 5
        weight = cal_weight > weight ? cal_weight : weight
        total_weight += weight
        total_cost += p.cost
        total_price += p.suggest_price
      end
      variant.price = ((total_price * (100 - product.sale_off.to_i))/100).round(2)
      compare_at_price = (variant.price * random/ 5).round(0) * 5
      product.update(suggest_price: variant.price, compare_at_price: compare_at_price, cost: total_cost, weight: total_weight)
    else
      compare_at_price = (variant.price * random/ 5).round(0) * 5
    end
    variant.compare_at_price = compare_at_price
    variant.save
  end
end