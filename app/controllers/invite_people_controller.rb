class InvitePeopleController < ApplicationController
  def index
    unless current_user.enable_ref == true
      redirect_to root_path
    end
  end

  def invite
    MiskreMailer.invite(current_user, params[:email]).deliver
    redirect_to invite_people_path, notice: "Succesfully!"
  end
end
