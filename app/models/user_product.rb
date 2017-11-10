# == Schema Information
#
# Table name: user_products
#
#  id                 :integer          not null, primary key
#  name               :string
#  weight             :integer
#  length             :integer
#  height             :integer
#  width              :integer
#  sku                :string
#  desc               :text
#  price              :float
#  compare_at_price   :float
#  quantity           :integer          default(0)
#  shopify_product_id :string
#  user_id            :integer
#  shop_id            :integer
#  is_request         :boolean          default(FALSE), not null
#  status             :string           default("")
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_user_products_on_shop_id  (shop_id)
#  index_user_products_on_user_id  (user_id)
#

class UserProduct < ApplicationRecord
	belongs_to :user
  belongs_to :shop
  has_many :user_variants, dependent: :destroy
  has_many :images, as: :imageable, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :sku, presence: true, uniqueness: true
  validates :quantity, numericality: { only_integer: true}
  validates :weight, presence: true, numericality: { only_integer: true,
                                       greater_than_or_equal_to: 1}

  before_save :default_values

 	def default_values
 		weight = self.weight
    if self.weight < 10
      weight = 10
    end
    if self.weight > 4000
      weight = 4000
    end
 	end

  def request!
    update(is_request: true, status: 'requested')
  rescue
    false
  end

  def approve!
    update(is_request: true, status: 'approved')
  rescue
    false
  end

  def self.requested
    where(is_request: true, status: 'requested')
  end
end
