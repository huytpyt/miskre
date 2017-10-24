class Variant < ApplicationRecord
  belongs_to :product
  has_many :images, as: :imageable, dependent: :destroy
  serialize :product_ids

end
