class Variant < ApplicationRecord
  belongs_to :product
  has_many :images, as: :imageable, dependent: :destroy
  serialize :product_ids

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0}
end
