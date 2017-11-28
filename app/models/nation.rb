# == Schema Information
#
# Table name: nations
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Nation < ApplicationRecord
  has_many :shipping_types, dependent: :destroy

  after_destroy :destroy_user_nation

  def destroy_user_nation
    UserNation.where(code: self.code).destroy_all
  end

  def self.search search
    if search
      where(['lower(name) LIKE ? OR lower(code) LIKE ?', "%#{search.downcase}%", "%#{search.downcase}%"])
    else
      scoped
    end
  end
end
