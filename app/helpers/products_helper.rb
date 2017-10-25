module ProductsHelper
  def variant_name product_name, variant
    "#{product_name}#{variant.option1.present? ? ' - ' + variant.option1 : ''}#{variant.option2.present? ? ' - ' + variant.option2 : ''}#{variant.option3.present? ? ' - ' + variant.option3 : ''}"
  end

  def find_product_name variant
    products = []
    variant.product_ids.each do |id|
      if id[:variant_id].nil?
        products.push(Product.find(id[:product_id]).name) 
      else
         products.push(variant_name(Product.find(id[:product_id]).name, variant))
      end
    end
    products.join(", ")
  end

  def find_product_name_from_bundle product
    products = []
    product.product_ids.each do |id|
      if id[:variant_id].nil?
        products.push(Product.find(id[:product_id]).name) 
      else
        products.push(variant_name(Product.find(id[:product_id]).name, Variant.find(id[:variant_id])))
      end
    end
    products.join(", ")
  end
end
