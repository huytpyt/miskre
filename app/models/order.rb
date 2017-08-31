class Order < ApplicationRecord
  belongs_to :shop

  validates :shopify_id, uniqueness: true
end
