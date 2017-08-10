class Supply < ApplicationRecord
  belongs_to :shop
  belongs_to :product
end
