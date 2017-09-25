class Option < ApplicationRecord
  belongs_to :product
  before_save :capitalize_values

  def capitalize_values
    self.values.map! do |v|
      v.split.map!(&:capitalize).join(' ')
    end
  end
end
