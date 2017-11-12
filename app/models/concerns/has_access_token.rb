module HasAccessToken
  extend ActiveSupport::Concern

  included do
    has_many :access_tokens, as: :resource, dependent: :destroy

    def class_scope
      self.class.name.try(:underscore).to_sym
    end

    def get_or_generate_api_key_by(scope = class_scope)
      AccessToken.get_or_generate_by(self, scope) if self.persisted?
    end

    def timeout_access_token_by(access_token)
      self.access_tokens.where(access_token: access_token).each(&:timeout!)
    end

    def self.find_by_acess_token(access_token)
      AccessToken.resource_by_access_token(access_token, self.name).try(:resource)
    end
  end
end
