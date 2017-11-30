# == Schema Information
#
# Table name: products
#
#  id                   :integer          not null, primary key
#  name                 :string
#  weight               :integer          default(0)
#  length               :float            default(0.0)
#  height               :float            default(0.0)
#  width                :float            default(0.0)
#  sku                  :string
#  desc                 :text
#  price                :float
#  compare_at_price     :float
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  shopify_id           :string
#  cost                 :float
#  link                 :text
#  epub                 :float
#  dhl                  :float
#  vendor               :string           default("Miskre")
#  bundle_id            :integer
#  is_bundle            :boolean          default(FALSE)
#  quantity             :integer          default(0)
#  product_ids          :string
#  user_id              :integer
#  product_url          :string
#  fulfillable_quantity :integer
#  cus_epub             :float
#  cus_dhl              :float
#  suggest_price        :float
#  cus_cost             :float
#  sale_off             :integer
#  shop_owner           :boolean          default(FALSE)
#  shop_id              :integer
#  resource_url         :string
#  vendor_detail        :text
#  cost_per_quantity    :string
#  approved             :boolean          default(FALSE)
#
# Indexes
#
#  index_products_on_bundle_id  (bundle_id)
#  index_products_on_user_id    (user_id)
#

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
