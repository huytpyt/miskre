# == Schema Information
#
# Table name: request_products
#
#  id           :integer          not null, primary key
#  product_name :text
#  link         :string
#  status       :boolean          default(FALSE)
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_request_products_on_user_id  (user_id)
#

class RequestProduct < ApplicationRecord
  belongs_to :user
  has_many :image_requests, dependent: :destroy
end
