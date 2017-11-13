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

class SupplyVariant < ApplicationRecord
  belongs_to :variant
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0}
  validates :compare_at_price, presence: true, numericality: { greater_than_or_equal_to: 0}

end
