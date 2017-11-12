module Api::ExceptionHandleController
  extend ActiveSupport::Concern

  class ForbiddenError < StandardError
  end

  class UnauthrizedError < StandardError
  end

  included do
    include AuthenticationController

    # Exception
    rescue_from Exception, with: :handle_exception
    rescue_from UnauthrizedError, with: :handle_unauthorized
    rescue_from ForbiddenError, with: :handle_forbidden
    rescue_from ActionController::RoutingError, with: :handle_not_found
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found

    protected

    def handle_not_found(e = nil)
      render nothing: true, status: 404
    end

    def handle_forbidden(e = nil)
      render json: {
          error: {
              code: "error.forbidden",
              message: "You do not have permission. #{e.message}",
          }
      }, status: 403
    end

    def handle_unauthorized(e = nil)
      render json: {
          error: {
              code: "error.unauthorized",
              message: "Authentication failed. #{e.message}",
          }
      }, status: 401
    end

    def handle_exception(e = nil)
      Rails.logger.error("error: #{e.class.name}:#{e.message}\n#{e.backtrace[0..10].join("\n")}")
      render json: {
          error: {
              code: "error.internal_server_error",
              message: "Internal server error #{e.message}",
          }
      }, status: 500
    end

    def handle_validation_error(e = nil)
      render json: {
          error: {
              code: "error.validation",
              message: "Validation error #{e.message}",
              details: e.record.errors.full_messages
          }
      }, status: 400
    end

    def not_found!
      raise ActionController::RoutingError.new('Not Found')
    end

    def error_unauthorized!
      raise UnauthrizedError.new
    end

    def error_forbidden!
      raise ForbiddenError.new
    end

    def error_unknown_resource!
      raise ActionController::RoutingError.new('Unknown Resource')
    end

    def raise_validations_if_error(target_model)
      raise ActiveRecord::RecordInvalid.new(target_model) if target_model.errors.present?
    end

  end

end
