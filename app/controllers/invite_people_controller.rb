class InvitePeopleController < ApplicationController
  def index
  end

  def invite
    MiskreMailer.invite(current_user, params[:email]).deliver
    redirect_to invite_people_path, notice: "Succesfully!"
  end
end
