# == Schema Information
#
# Table name: product_needs
#
#  id         :integer          not null, primary key
#  product_id :integer
#  variant_id :integer
#  quantity   :integer
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ProductNeed < ApplicationRecord
  has_many :bid_transactions
  enum status: [:suspend, :running, :finish]
end
