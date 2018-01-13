# == Schema Information
#
# Table name: inventories
#
#  id         :integer          not null, primary key
#  product_id :integer
#  quantity   :integer
#  cost       :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Inventory < ApplicationRecord
  belongs_to :product

  scope :in_stock, ->{ where("quantity > 0").order("cost DESC") }

  def self.search search
    if search
        where("CAST(product_id AS TEXT) LIKE :search", { search: "%#{search.downcase}%" })
    else
      scoped
    end
  end
end
