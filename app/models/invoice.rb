# == Schema Information
#
# Table name: invoices
#
#  id           :integer          not null, primary key
#  type         :string
#  user_id      :string
#  money_amount :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Invoice < ApplicationRecord
  belongs_to :user
  has_many :orders
end
