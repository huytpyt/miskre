# == Schema Information
#
# Table name: shipping_types
#
#  id           :integer          not null, primary key
#  code         :text
#  time_range   :text
#  nation_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  has_handling :boolean          default(TRUE)
#
# Indexes
#
#  index_shipping_types_on_nation_id  (nation_id)
#

class ShippingType < ApplicationRecord
  has_many :detail_shipping_types, dependent: :destroy
  has_many :detail_no_handlings, dependent: :destroy
  belongs_to :nation

  after_destroy :destroy_user_shipping_type

  def destroy_user_shipping_type
    UserShippingType.where(shipping_type_id: self.id).destroy_all
  end
end
