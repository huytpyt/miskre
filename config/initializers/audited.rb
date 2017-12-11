require 'set'

module Audited
  class Audit < ::ActiveRecord::Base
    private

    def set_version_number
      max = self.class.auditable_finder(auditable_id, auditable_type).descending.first.try(:version) || 0
      self.version = max + 1
    end

    def set_audit_user
      user = ::Audited.store[:current_user].try!(:call)
      if user
        self.user_id = user.id
        self.user_type = user.role
        self.username = user.name
      end
      nil # prevent stopping callback chains
    end

    def set_request_uuid
      self.request_uuid ||= ::Audited.store[:current_request_uuid]
      self.request_uuid ||= SecureRandom.uuid
    end

    def set_remote_address
      self.remote_address ||= ::Audited.store[:current_remote_address]
    end
  end
end