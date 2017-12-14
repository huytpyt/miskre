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
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (user_id => users.id)
#

class Option < ApplicationRecord
  audited associated_with: :product
  belongs_to :product
end
