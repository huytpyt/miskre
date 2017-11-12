# == Schema Information
#
# Table name: tracking_products
#
#  id         :integer          not null, primary key
#  open       :integer
#  high       :integer
#  low        :integer
#  close      :integer
#  product_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tracking_products_on_product_id  (product_id)
#

class TrackingProduct < ApplicationRecord
  belongs_to :product
end
