# == Schema Information
#
# Table name: shippings
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  min_price    :float
#  max_price    :text
#  percent_dhl  :integer
#  percent_epub :integer
#  name_dhl     :text
#  name_epub    :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_shippings_on_user_id  (user_id)
#

class Shipping < ApplicationRecord
  belongs_to :user
end
