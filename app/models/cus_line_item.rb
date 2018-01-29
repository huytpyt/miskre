# == Schema Information
#
# Table name: cus_line_items
#
#  id                   :integer          not null, primary key
#  customer_id          :integer
#  sku                  :string
#  quantity             :integer
#  shopify_line_item_id :string
#  price                :string
#  title                :string
#  name                 :string
#  on_system            :boolean
#  shop_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class CusLineItem < ApplicationRecord
  belongs_to :customer

  after_commit do
    total_quantity = customer.cus_line_items.inject(0){|total_quantity, item| total_quantity += item.quantity }
    customer.total_quantity = total_quantity
    customer.save
  end
end
