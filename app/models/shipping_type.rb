class ShippingType < ApplicationRecord
  has_many :detail_shipping_types, dependent: :destroy
  has_many :detail_no_handlings, dependent: :destroy
  belongs_to :nation

  after_destroy :destroy_user_shipping_type

  def destroy_user_shipping_type
    UserShippingType.where(shipping_type_id: self.id).destroy_all
  end
end
