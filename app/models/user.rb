class User < ApplicationRecord
  extend Enumerize
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  enumerize :role, in: [:admin, :manager, :user],
    default: :user, predicates: true

  has_many :shops
  has_many :products

  def staff?
    self.admin? || self.manager?
  end
end
