class Nation < ApplicationRecord
  has_many :shipping_types, dependent: :destroy

  after_destroy :destroy_user_nation

  def destroy_user_nation
    UserNation.where(code: self.code).destroy_all
  end
end
