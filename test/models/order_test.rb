# == Schema Information
#
# Table name: orders
#
#  id                   :integer          not null, primary key
#  first_name           :string
#  last_name            :string
#  ship_address1        :string
#  ship_address2        :string
#  ship_city            :string
#  ship_state           :string
#  ship_zip             :string
#  ship_country         :string
#  ship_phone           :string
#  email                :string
#  quantity             :integer
#  skus                 :text
#  unit_price           :text
#  date                 :datetime
#  remark               :string
#  shipping_method      :string
#  tracking_no          :string
#  fulfill_fee          :float
#  product_name         :text
#  color                :string
#  size                 :string
#  shop_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  shopify_id           :string
#  financial_status     :string
#  fulfillment_status   :string
#  paid_for_miskre      :boolean          default(FALSE)
#  invoice_id           :integer
#  request_charge_id    :integer
#  order_name           :string
#  country_code         :string
#  tracking_number_real :string
#  stock_warning        :string
#  pickup_info          :string
#
# Indexes
#
#  index_orders_on_shop_id     (shop_id)
#  index_orders_on_shopify_id  (shopify_id)
#
# Foreign Keys
#
#  orders_shop_id_fkey  (shop_id => shops.id)
#

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
