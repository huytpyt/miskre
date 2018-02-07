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
