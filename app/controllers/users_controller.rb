class UsersController < ApplicationController
  before_action :set_user
  def index
    
  end

  def update
    @user.update(get_users_params)
    redirect_to users_path, notice: "Update succesfully!"
  end

  private
  def set_user
    @user = current_user
  end
  def get_users_params
    params[:user][:password].present? ? params.require(:user).permit(:name, :fb_link, :password, :password_confirmation) : params.require(:user).permit(:name, :fb_link)
  end
end