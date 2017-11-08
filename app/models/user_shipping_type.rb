class UserShippingType < ApplicationRecord
  belongs_to :user_nation
  has_many :shipping_settings
  belongs_to :shipping_type, foreign_key: "shipping_type_id"
end
