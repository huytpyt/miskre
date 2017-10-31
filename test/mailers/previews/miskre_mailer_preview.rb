# Preview all emails at http://localhost:3000/rails/mailers/miskre_mailer
class MiskreMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/miskre_mailer/invite
  def invite
    MiskreMailer.invite
  end

end
