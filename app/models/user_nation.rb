class UserNation < ApplicationRecord
  belongs_to :user
  has_many :user_shipping_types, dependent: :destroy
end
