# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :string
#  customer_id            :string
#  is_paid                :boolean          default(FALSE)
#  period_end             :datetime
#  parent_id              :integer
#  reference_code         :text
#  enable_ref             :boolean          default(FALSE)
#  name                   :text
#  fb_link                :text
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  include HasAccessToken
  extend Enumerize
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  enumerize :role, in: [:admin, :manager, :partner, :user],
    default: :user, predicates: true

  has_one :balance
  has_many :shops
  has_many :products
  has_many :shippings
  has_many :childs, class_name: "Users", foreign_key: "parent_id"
  has_many :request_products
  has_many :user_products
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
      ShippingService.delay.sync_shipping_for_user self
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

  def self.ceo
    User.find_by_email("duy@miskre.com")
  end
end
