# == Schema Information
#
# Table name: customers
#
#  id               :integer          not null, primary key
#  shopify_order_id :string
#  email            :string
#  token            :string
#  fullname         :string
#  ship_address1    :string
#  ship_address2    :string
#  ship_city        :string
#  ship_state       :string
#  ship_zip         :string
#  ship_country     :string
#  ship_phone       :string
#  shipping_method  :string
#  country_code     :string
#  total_quantity   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Customer < ApplicationRecord
  has_many :cus_line_items, dependent: :destroy

  def generate_token
    self.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Customer.exists?(token: random_token)
    end
  end

  def self.search(search)
    if search
        where("lower(email) LIKE :search OR lower(fullname) LIKE :search
         OR lower(token) LIKE :search
         OR lower(ship_city) LIKE :search
         OR lower(ship_state) LIKE :search
         OR lower(ship_zip) LIKE :search
         OR lower(ship_country) LIKE :search
         OR lower(ship_phone) LIKE :search
         OR lower(shipping_method) LIKE :search
         OR lower(shopify_order_id) LIKE :search
         OR lower(country_code) LIKE :search
         OR lower(ship_address1) LIKE :search OR lower(ship_address2) LIKE :search", { search: "%#{search.downcase}%" })
    else
      scoped
    end
  end
end
