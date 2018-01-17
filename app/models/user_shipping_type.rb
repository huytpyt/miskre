# == Schema Information
#
# Table name: user_shipping_types
#
#  id               :integer          not null, primary key
#  user_nation_id   :integer
#  shipping_type_id :integer
#  active           :boolean          default(TRUE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_user_shipping_types_on_user_nation_id  (user_nation_id)
#
# Foreign Keys
#
#  user_shipping_types_user_nation_id_fkey  (user_nation_id => user_nations.id)
#

class UserShippingType < ApplicationRecord
  belongs_to :user_nation
  has_many :shipping_settings, dependent: :destroy
  belongs_to :shipping_type, foreign_key: "shipping_type_id"
end
