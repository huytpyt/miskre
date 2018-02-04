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

  validate :one_suplier_one_product, on: [:create]
  validate :product_need_valid
  validates :supplier_id, presence: true, numericality: true
  validates :product_need_id, presence: true, numericality: true
  validates_numericality_of :cost, presence: true, greater_than_or_equal_to: 0

  enum status: [:pending, :reject, :success]
  private
  def one_suplier_one_product
  	if BidTransaction.where(supplier_id: self.supplier_id, product_need_id: self.product_need_id).present?
  	  errors.add(:many_time, "Supplier can auction only one time")
  	end
  end

  def product_need_valid
  	unless product_need.present?
  		errors.add(:product_need, "This auction transaction not present")
  	end
  end
end
