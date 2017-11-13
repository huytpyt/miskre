# == Schema Information
#
# Table name: detail_shipping_types
#
#  id               :integer          not null, primary key
#  weight_from      :float
#  weight_to        :float
#  cost             :float
#  handling_fee     :float
#  shipping_type_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_detail_shipping_types_on_shipping_type_id  (shipping_type_id)
#

class DetailShippingType < ApplicationRecord
  belongs_to :shipping_type
end
