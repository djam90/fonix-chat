class DigestMailer < ApplicationMailer
  helper DigestMailerHelper

  def weekly(user, period_end: Time.current)
    @digest = WeeklyDigest.new(user, period_end: period_end)
    mail subject: "Your weekly Fonix Chat summary", to: user.email
  end
end
