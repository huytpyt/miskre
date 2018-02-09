# == Schema Information
#
# Table name: vendors
#
#  id         :integer          not null, primary key
#  name       :string
#  address    :string
#  phone      :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Vendor < ApplicationRecord
  has_many :inventories

  def self.search(search)
    if search
        where("lower(email) LIKE :search
         OR lower(name) LIKE :search
         OR lower(address) LIKE :search
         OR lower(phone) LIKE :search", { search: "%#{search.downcase}%" })
    else
      scoped
    end
  end
end
