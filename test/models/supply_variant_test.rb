# == Schema Information
#
# Table name: supply_variants
#
#  id               :integer          not null, primary key
#  option1          :string
#  option2          :string
#  option3          :string
#  price            :float
#  sku              :string
#  compare_at_price :float
#  supply_id        :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_supply_variants_on_supply_id  (supply_id)
#

require 'test_helper'

class SupplyVariantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
