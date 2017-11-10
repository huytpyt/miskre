# == Schema Information
#
# Table name: image_requests
#
#  id                 :integer          not null, primary key
#  file_file_name     :string
#  file_content_type  :string
#  file_file_size     :integer
#  file_updated_at    :datetime
#  request_product_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_image_requests_on_request_product_id  (request_product_id)
#

class ImageRequest < ApplicationRecord
  belongs_to :request_product
end
