class Api::V1::BaseController < Api::ApiController
	include Api::ExceptionHandleController
  include Api::AuthenticationController
  include Api::AuthorizationController
  include Api::RecordNotFoundController

	skip_before_action :site_http_basic_authenticate_with, raise: false
  skip_before_action :verify_authenticity_token
	protect_from_forgery with: :null_session

	before_action :authenticate_any!, if: :skip_new_session

  before_filter :add_allow_credentials_headers

  def add_allow_credentials_headers
    response.headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*'
    response.headers['Access-Control-Allow-Credentials'] = 'true'
  end 

	def headers
    request.env
  end

  def header(name, value)
    response.headers[name] = value
  end

  # =============================
  # Exception
  #
  def handle_not_found(e = nil)
    render nothing: true, status: 404
  end

  def handle_forbidden(e = nil)
    render json: {error: "You do not have permission."}, status: 403
  end

  def handle_unauthorized(e = nil)
    render json: {error: "Authentication failed."}, status: 401
  end

  def handle_not_destroy(e = nil)
    message = e.message
    errorData = {
        error: message,
    }
    render json: errorData, status: 400
  end

  def handle_exception(e = nil)
    Rails.logger.error("error: #{e.class.name}:#{e.message}\n#{e.backtrace[0..10].join("\n")}")
    render json: {error: "Internal server error #{e.message}"}, status: 500
  end

  private

    def skip_new_session
      !(controller_name.include?('session') && action_name == 'create')
    end
end
