module ProductsHelper
  def variant_name product_name, variant
    "#{product_name}#{variant.option1.present? ? ' - ' + variant.option1 : ''}#{variant.option2.present? ? ' - ' + variant.option2 : ''}#{variant.option3.present? ? ' - ' + variant.option3 : ''}"
  end
end
