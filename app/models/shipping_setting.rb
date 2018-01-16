# == Schema Information
#
# Table name: shipping_settings
#
#  id                    :integer          not null, primary key
#  user_shipping_type_id :integer
#  min_price             :float
#  max_price             :text
#  percent               :integer
#  packet_name           :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_shipping_settings_on_user_shipping_type_id  (user_shipping_type_id)
#
# Foreign Keys
#
#  shipping_settings_user_shipping_type_id_fkey  (user_shipping_type_id => user_shipping_types.id)
#

class ShippingSetting < ApplicationRecord
  belongs_to :user_shipping_type
end
