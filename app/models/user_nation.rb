# == Schema Information
#
# Table name: user_nations
#
#  id         :integer          not null, primary key
#  code       :text
#  name       :text
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_user_nations_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_nations_user_id_fkey  (user_id => users.id)
#

class UserNation < ApplicationRecord
  belongs_to :user
  has_many :user_shipping_types, dependent: :destroy
end
