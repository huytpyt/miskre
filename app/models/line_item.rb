# == Schema Information
#
# Table name: line_items
#
#  id                   :integer          not null, primary key
#  product_id           :integer
#  order_id             :integer
#  quantity             :integer
#  sku                  :string
#  variant_id           :string
#  total_discount       :float
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  price                :float
#  grams                :integer
#  title                :string
#  name                 :string
#  variant_title        :string
#  fulfillable_quantity :integer
#  fulfillment_status   :string
#  line_item_id         :string
#
# Indexes
#
#  index_line_items_on_order_id    (order_id)
#  index_line_items_on_product_id  (product_id)
#

class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :order
end
