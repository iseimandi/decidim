class InitialUserMailer < ApplicationMailer

  def invitation_email(user, token)
    @user = user
    @resource = user
    @token = token
    mail(to: @user.email, subject: "Benvingut/da a la plataforma de participació de Reus.")
  end

end
