class Variant < ApplicationRecord
  belongs_to :product
  # has_many :images, as: :imageable
  has_many :images, as: :imageable, dependent: :destroy
end
