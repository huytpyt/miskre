# == Schema Information
#
# Table name: resource_images
#
#  id                :integer          not null, primary key
#  file_file_name    :string
#  file_content_type :string
#  file_file_size    :integer
#  file_updated_at   :datetime
#  product_id        :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_resource_images_on_product_id  (product_id)
#

require 'test_helper'

class ResourceImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
