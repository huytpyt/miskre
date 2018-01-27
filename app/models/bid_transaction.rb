# == Schema Information
#
# Table name: bid_transactions
#
#  id              :integer          not null, primary key
#  supplier_id     :integer
#  product_need_id :integer
#  cost            :decimal(, )
#  time            :date
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class BidTransaction < ApplicationRecord
  belongs_to :supplier
  belongs_to :product_need
end
