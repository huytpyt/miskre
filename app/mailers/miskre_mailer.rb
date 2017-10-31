class MiskreMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.miskre_mailer.invite.subject
  #
  def invite user, email
    @user = user
    mail(from: "Miskre<#{ENV['USER_MAIL_SERVER']}>", to: email, subject: "You're invited to join the Miskre")
  end
end
