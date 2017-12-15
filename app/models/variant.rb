# == Schema Information
#
# Table name: variants
#
#  id               :integer          not null, primary key
#  option1          :string
#  option2          :string
#  option3          :string
#  quantity         :integer
#  price            :float            default(0.0)
#  sku              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  product_id       :integer
#  user_id          :integer
#  compare_at_price :float
#  product_ids      :string
#
# Indexes
#
#  index_variants_on_product_id  (product_id)
#  index_variants_on_user_id     (user_id)
#
# Foreign Keys
#
#  variants_product_id_fkey  (product_id => products.id)
#  variants_user_id_fkey     (user_id => users.id)
#

class Variant < ApplicationRecord
  audited associated_with: :product
  belongs_to :product
  has_many :images, as: :imageable, dependent: :destroy
  serialize :product_ids

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0}
end
