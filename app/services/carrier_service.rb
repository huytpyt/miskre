class CarrierService
  def self.get_epub_cost(country_code, weight)
    country_cost = (EPUB.key? country_code) ? EPUB[country_code] : EPUB['US']

    country_cost.each do |weight_limit, price|
      return price if weight <= weight_limit
    end

    return 20.00
  end

  def self.get_dhl_cost(country_code, weight)
    country_cost = (DHL.key? country_code) ? DHL[country_code] : DHL['US']

    country_cost.each do |weight_limit, price|
      return price if weight <= weight_limit
    end

    return 500.00
  end
end
