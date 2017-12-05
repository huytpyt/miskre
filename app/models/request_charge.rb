# == Schema Information
#
# Table name: request_charges
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  total_amount :decimal(, )
#  status       :integer          default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class RequestCharge < ApplicationRecord
  belongs_to :user
  has_many :orders

  enum status: %w(pending approved rejected)

  def self.search(search)
    if search
        where("CAST(user_id AS TEXT) LIKE :search OR CAST(total_amount AS TEXT) LIKE :search
         OR status = :search_status
         OR CAST(id AS TEXT) LIKE :search", { search: "%#{search.downcase}%", search_status: RequestCharge.statuses["#{search}"] })
    else
      scoped
    end
  end
end
