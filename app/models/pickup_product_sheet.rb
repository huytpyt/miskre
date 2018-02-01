# == Schema Information
#
# Table name: pickup_product_sheets
#
#  id         :integer          not null, primary key
#  file_name  :string
#  status     :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PickupProductSheet < ApplicationRecord
  has_many :orders

  enum status: %w(picking done)

end
