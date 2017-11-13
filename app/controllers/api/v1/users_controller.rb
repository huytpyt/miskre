class Api::V1::UsersController < Api::V1::BaseController
  def show
  	user = current_resource
    render json: {
  		id: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
      customer_id: user.customer_id,
      is_paid: user.is_paid,
      period_end: user.period_end,
      parent_id: user.parent_id,
      reference_code: user.reference_code,
      enable_ref: user.enable_ref,
      fb_link: user.fb_link
  	}, status: 200
  end
end
