# == Schema Information
#
# Table name: access_tokens
#
#  id            :integer          not null, primary key
#  scope         :string
#  access_token  :string
#  expires_at    :datetime
#  resource_type :string           not null
#  resource_id   :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_access_tokens_on_access_token                   (access_token) UNIQUE
#  index_access_tokens_on_resource_type_and_resource_id  (resource_type,resource_id)
#

class AccessToken < ApplicationRecord
	before_create :generate_access_token
  belongs_to :resource, polymorphic: true

  def expired?
    Time.now.utc >= self.expires_at
  end

  def touch!
    self.set_expiration
    self.save!
    self
  end

  def timeout!
    self.expires_at = Time.now.utc
    self.save!
  end

  before_create :set_expiration

  def set_expiration
    self.expires_at = self.class.expire_time
  end

  class << self

    def expire_time
      (Time.now.utc + 10.days)
    end

    def get_or_generate_by(resource, scope)
      api_key = self.where(resource_id: resource.id, scope: scope).first
      if api_key.nil?
        api_key = self.find_or_create_by(resource_id: resource.id, scope: scope) do |s|
          s.resource = resource
          s.scope = scope
          s.set_expiration
          logger.info("expires_at1: #{s.expires_at}")
        end
      else
        logger.info("expires_at2: #{api_key.expires_at}")
        api_key.touch!
        logger.info("expires_at3: #{api_key.expires_at}")
        api_key
      end

    end

    def find_by_acess_token(access_token)
      self.where(access_token: access_token).first
    end

    def destroy_by_acess_token(access_token)
      self.where(access_token: access_token).delete_all
    end

    def resource_by_access_token(access_token, scope = nil)
      return nil if access_token.nil?
      api_key = AccessToken.find_by_acess_token(access_token)
      if api_key.nil?
        logger.info("none")
        nil
      elsif api_key.expired? # 期限切れ
        logger.info("expired?")
        nil
      elsif scope.present? && api_key.scope.to_sym != scope.to_sym
        logger.info("expired? #{scope}")
        nil
      else
        api_key
      end
    end
  end

  protected

  def generate_access_token
    begin
      self.access_token = Devise.friendly_token
    end while self.class.where(access_token: access_token).exists?
  end
end
