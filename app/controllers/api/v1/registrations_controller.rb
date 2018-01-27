class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    resource = User.new(sign_up_params_new)
    if params[:registration_type] == "supplier"
      resource.save
      supplier = Supplier.new(supplier_params)
      supplier.user_id = resource.id
      supplier.save
    else
      parent_ref_code = sign_up_params_new[:reference_code]
      ref_code = UserService.new.generate_ref_code
      parent_user = User.where(reference_code: parent_ref_code).first
      if parent_ref_code.present? && User.exists?(reference_code: parent_ref_code) && parent_user.enable_ref
        resource.parent_id = User.find_by_reference_code(parent_ref_code).id
      elsif !parent_user.enable_ref
        return render json: { result: "Failed", error: "The user has this reference code does not have permission to invite new user", user: nil }, status: 200
      elsif parent_ref_code.blank?
        return render json: { result: "Failed", error: "You must have reference code to sign up", user: nil }, status: 200
      elsif !User.exists?(reference_code: parent_ref_code)
        return render json: { result: "Failed", error: "Your reference code is invalid", user: nil }, status: 200
      end

      unless User.exists?(reference_code: ref_code)
        resource.reference_code = ref_code
        resource.save
      end
    end

    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        render json: { result: "Success", error: nil, user: resource }, status: 200
      else
        expire_data_after_sign_in!
        render json: { result: "Success", error: "signed_up_but_#{resource.inactive_message}", user: resource }, status: 200
      end
    else
      render json: { result: "Failed", error: resource.errors.messages, user: nil }, status: 200
      clean_up_passwords resource
      set_minimum_password_length
    end
  end

  private
  def sign_up_params_new
    params.permit(:email, :password_confirmation, :password, :name, :fb_link, :reference_code, :birthday, :phone)
  end

  def supplier_params
    params.permit(:company_name, :address, :active)
  end
end