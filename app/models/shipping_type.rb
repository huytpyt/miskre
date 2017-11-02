class ShippingType < ApplicationRecord
  has_many :detail_shipping_types
  has_many :detail_no_handlings
  belongs_to :nation
end
