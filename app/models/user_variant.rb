# == Schema Information
#
# Table name: user_variants
#
#  id               :integer          not null, primary key
#  name             :string
#  option1          :string
#  option2          :string
#  option3          :string
#  quantity         :integer          default(0)
#  price            :float
#  sku              :string
#  compare_at_price :float
#  user_product_id  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_user_variants_on_user_product_id  (user_product_id)
#
# Foreign Keys
#
#  user_variants_user_product_id_fkey  (user_product_id => user_products.id)
#

class UserVariant < ApplicationRecord
	belongs_to :user_product
	has_many :images, as: :imageable, dependent: :destroy

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0}
end
