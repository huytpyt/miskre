# == Schema Information
#
# Table name: detail_no_handlings
#
#  id               :integer          not null, primary key
#  weight_from      :integer
#  weight_to        :integer
#  cost             :float
#  shipping_type_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_detail_no_handlings_on_shipping_type_id  (shipping_type_id)
#

class DetailNoHandling < ApplicationRecord
  belongs_to :shipping_type
end
