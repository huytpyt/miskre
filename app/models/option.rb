class Option < ApplicationRecord
  belongs_to :product
  before_save :capitalize_values

  def capitalize_values
    self.values.map!(&:strip).map!(&:capitalize)
  end
end
