class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    @user = User.find user.id
    @url  = edit_password_reset_url(@user.reset_password_token)
    mail(:to => @user.email,
         :subject => "MGFD40 Project: Your password has been reset")
  end

  def completed_queue(user)
    @user = User.find user.id
    mail(:to => @user.email,
         :subject => "MGFD40 Project: Your files have completed uploading")
  end

  def error(user)
    @user = User.find user.id
    mail(:to => @user.email,
         :subject => "MGFD40 Project: Uploading error")
  end
end
