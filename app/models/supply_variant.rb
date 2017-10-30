class SupplyVariant < ApplicationRecord
  belongs_to :variant
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0}
  validates :compare_at_price, presence: true, numericality: { greater_than_or_equal_to: 0}

end
