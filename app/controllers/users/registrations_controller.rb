class Users::RegistrationsController < Devise::RegistrationsController
  prepend_before_action :require_no_authentication, only: [:new, :create, :cancel]
  prepend_before_action :authenticate_scope!, only: [:edit, :update, :destroy]
  prepend_before_action :set_minimum_password_length, only: [:new, :edit]

  def new
    if params[:ref].present? && User.exists?(reference_code: params[:ref])
      session[:resource].present? ? build_resource() : build_resource({})
      yield resource if block_given?
      respond_with resource
    else
      render "require_affilink"
    end
  end

  def create
    resource = User.new(sign_up_params_new)
    parent_ref_code = params[:ref]
    ref_code = user_service.generate_ref_code
    if parent_ref_code.present? && User.exists?(reference_code: parent_ref_code)
      resource.parent_id = User.find_by_reference_code(parent_ref_code).id
    end
    unless User.exists?(reference_code: ref_code)
      resource.reference_code = ref_code
      resource.save
    end
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)        
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        redirect_to user_complete_registration_path
      end
    else
      redirect_to new_user_session_path
      clean_up_passwords resource
      set_minimum_password_length
    end
  end

  protected
  
  def build_resource(hash=nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", force: true)
    self.resource = send(:"current_#{resource_name}")
  end

  private
  def user_service
    @user_service ||= UserService.new 
  end

  def sign_up_params_new
    params.require(:user).permit(:email, :password_confirmation, :password, :name, :fb_link)
  end
end
