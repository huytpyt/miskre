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
  has_many :childs, class_name: "Users", foreign_key: "parent_id"
  has_many :request_products
  after_create :create_customer

  has_many :user_nations, dependent: :destroy
  # def send_devise_notification(notification, *args)
  #   devise_mailer.send(notification, self, *args).deliver_later
  # end

  def staff?
    self.admin? || self.manager?
  end

  def create_customer
    if self.user?
      ShippingService.sync_shipping_for_user self
    end
    customer = Stripe::Customer.create(:email => self.email)
    self.update(customer_id: customer.id)
  end

  def self.admins
    where(role: 'admin').order(id: :asc)
  end 

  def self.master_admin
    User.admins.first
  end   
end
