class CarrierService

  WEIGHTS = [60, 100, 150, 200, 250, 300, 350, 400, 450, 500, 550, 600, 650, 700, 750, 800, 850, 900, 1000]

  def self.get_epub_price(country, weight)
    EPUB[country][get_weight(weight)]
  end

  def self.get_weight(weight)
    WEIGHTS.each do |w|
      return w if weight <= w
    end
    return 1000
  end
end
