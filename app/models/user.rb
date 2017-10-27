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
  after_create :create_customer
  
  def staff?
    self.admin? || self.manager?
  end

  def create_customer
    customer = Stripe::Customer.create(:email => self.email)
    self.update(customer_id: customer.id)
  end    
end
