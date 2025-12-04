# frozen_string_literal: true

class UserVerificationMailer < ApplicationMailer
  def on_accepted(user_id)
    @user_email = User.find(user_id).email
    mail(
      from: 'verificaciones@soporte.plebisbrand.info',
      to: @user_email,
      subject: 'PlebisBrand, Datos verificados'
    )
  end

  def on_rejected(user_id)
    @user_email = User.find(user_id).email

    mail(
      from: 'verificaciones@soporte.plebisbrand.info',
      to: @user_email,
      subject: 'PlebisBrand, no hemos podido realizar la verificación'
    )
  end
end
