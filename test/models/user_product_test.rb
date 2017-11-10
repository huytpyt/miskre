# == Schema Information
#
# Table name: user_products
#
#  id                 :integer          not null, primary key
#  name               :string
#  weight             :integer
#  length             :integer
#  height             :integer
#  width              :integer
#  sku                :string
#  desc               :text
#  price              :float
#  compare_at_price   :float
#  quantity           :integer          default(0)
#  shopify_product_id :string
#  user_id            :integer
#  shop_id            :integer
#  is_request         :boolean          default(FALSE), not null
#  status             :string           default("")
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_user_products_on_shop_id  (shop_id)
#  index_user_products_on_user_id  (user_id)
#

require 'test_helper'

class UserProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
