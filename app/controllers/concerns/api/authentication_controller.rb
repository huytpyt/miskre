module Api::AuthenticationController
  extend ActiveSupport::Concern

  included do

    RESOURCES = %i( user ).freeze

    def access_token
      @access_token ||= headers['X-Miskre-AccessToken'] || headers['HTTP_X_MISKRE_ACCESSTOKEN']
    end

    def current_access_token
      @current_access_token ||= AccessToken.resource_by_access_token(access_token)
    end

    def current_resource
      @current_resource ||= current_access_token.try(:resource)
    end

    def current_resource_name
      current_resource.class.name.underscore.to_sym
    end

    def current_scope
      @current_scope ||= current_access_token.try(:scope).try(:to_sym)
    end

    def current_scoped_owner
      @current_scoped_object ||= current_resource
    end

    def signed_in_any?(resource_names)
      current_resource.present? && resource_names.include?(current_resource.class.name.underscore.to_sym)
    end

    def signed_in?(resource_name)
      current_resource.present? && current_resource.class.name.underscore.to_sym == resource_name.to_sym
    end

    def authenticate!(resource_name=nil)
      if resource_name.nil?
        error_unauthorized! if current_resource.nil?
      else
        error_unauthorized! unless signed_in?(resource_name)
      end
    end

    def authenticate_any!(resource_names=nil)
      if resource_names
        error_unauthorized! unless signed_in_any?(resource_names)
      else
        error_unauthorized! unless signed_in_any?(RESOURCES)
      end

    end

    RESOURCES.each do |resource_name|
      class_eval <<-METHODS, __FILE__, __LINE__ + 1
          def current_#{resource_name}
            current_resource if signed_in?(:#{resource_name})
          end

          def #{resource_name}_signed_in?
            signed_in?(:#{resource_name})
          end

          def authenticate_#{resource_name}!
            authenticate!(:#{resource_name})
          end

          def master_#{resource_name}?
            current_#{resource_name} && current_#{resource_name}.master?
          end
      METHODS
    end

  end

end
