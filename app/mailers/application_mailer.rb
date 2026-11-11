class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "Fonix Chat <no-reply@fonix-chat.test>")
  layout "mailer"
end
