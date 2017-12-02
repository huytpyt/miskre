# == Schema Information
#
# Table name: options
#
#  id         :integer          not null, primary key
#  name       :string
#  values     :string           default([]), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :integer
#  user_id    :integer
#
# Indexes
#
#  index_options_on_product_id  (product_id)
#  index_options_on_user_id     (user_id)
#
# Foreign Keys
#
#  options_product_id_fkey  (product_id => products.id)
#  options_user_id_fkey     (user_id => users.id)
#

require 'test_helper'

class OptionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
