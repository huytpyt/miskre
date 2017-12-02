# == Schema Information
#
# Table name: balances
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  total_amount :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Balance < ApplicationRecord
  belongs_to :user
end
