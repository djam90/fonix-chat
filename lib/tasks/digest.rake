namespace :digest do
  desc "Send the weekly digest email to every confirmed user right now"
  # Sends with deliver_now rather than running WeeklyDigestJob, whose deliver_later emails
  # would be lost when this one-off process exits in development.
  task deliver: :environment do
    users = User.confirmed
    users.find_each { |user| DigestMailer.weekly(user).deliver_now }
    puts "Sent the weekly digest to #{users.count} #{"user".pluralize(users.count)}."
  end
end
