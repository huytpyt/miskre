# == Schema Information
#
# Table name: suppliers
#
#  id           :integer          not null, primary key
#  company_name :string
#  address      :string
#  activate     :boolean
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Supplier < ApplicationRecord
  belongs_to :user
  has_many :bid_transactions
end
