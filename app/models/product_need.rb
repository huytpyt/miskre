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

  class << self
    def search search
      if search
        where("status = :search_status
         OR CAST(product_id AS TEXT) LIKE :search
         OR CAST(variant_id AS TEXT) LIKE :search", { search: "%#{search.downcase}%", search_status: ProductNeed.statuses["#{search}"] })
      else
        scoped
      end
    end
  end
end
