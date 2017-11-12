class Api::V1::Resource::SessionsController < Api::V1::Resource::ApiController

  before_action only: [:index, :destroy] do
    authenticate!(scoped_resource_name)
  end

  def index
    render json: AccessToken.where(resource: current_resource)
  end

  def create
    resource = scoped_resource_class.where(email: session_create_params[:email]).first
    if resource
      error_unauthorized! unless resource.valid_password?(session_create_params[:password])
      token = resource.get_or_generate_api_key_by(scope)
      render json: {
          stage: Rails.env.to_s,
          scope: scope.to_s,
          accessToken: token.access_token,
          expiresAt: token.expires_at,
          resource: {
              id: resource.id,
              email: resource.email,
              name: resource.name,
              role: resource.role
          }
      }
    else
      error_unauthorized!
    end
  end

  def show
    token = AccessToken.resource_by_access_token(access_token, scope)
    error_unauthorized! if token.nil?
    resource = token.resource
    render json: {
        stage: Rails.env.to_s,
        scope: token.scope.to_s,
        expiresAt: token.expires_at,
        resource: {
          id: resource.id,
          email: resource.email,
          name: resource.name,
          role: resource.role
        }
    }
  end

  def update
    token = AccessToken.resource_by_access_token(access_token, scope)
    error_unauthorized! if token.nil?
    resource = token.resource
    token.touch!
    render json: {
        stage: Rails.env.to_s,
        scope: token.scope,
        expires_at: token.expires_at,
        resource: {
          id: resource.id,
          email: resource.email,
          name: resource.name,
          role: resource.role
        }
    }
  end

  def destroy
    if current_resource
      current_resource.timeout_access_token_by(access_token)
    end
    head :no_content
  end

  protected

  def session_create_params
    params.permit(:email, :password)
  end

end
