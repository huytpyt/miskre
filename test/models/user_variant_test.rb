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
#  fk_rails_...  (user_product_id => user_products.id)
#

require 'test_helper'

class UserVariantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
