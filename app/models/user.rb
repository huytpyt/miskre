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
  has_many :shippings
  
  after_create :create_customer
  
  def staff?
    self.admin? || self.manager?
  end

  def create_customer
    self.shippings.create(min_price: 0, max_price: 35, name_epub: "Insured Shipping", name_dhl: "Expedited Insured Shipping", percent_epub: 100, percent_dhl: 100)
    self.shippings.create(min_price: 35, max_price: "infinity", name_epub: "Free Insured Shipping", name_dhl: "DHL (not free)", percent_epub: 0, percent_dhl: 100)
    customer = Stripe::Customer.create(:email => self.email)
    self.update(customer_id: customer.id)
  end    
end
