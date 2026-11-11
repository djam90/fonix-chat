namespace :digest do
  desc "Send the weekly digest email to every confirmed user right now"
  task deliver: :environment do
    users = User.confirmed
    users.find_each { |user| DigestMailer.weekly(user).deliver_now }
    puts "Sent the weekly digest to #{users.count} #{"user".pluralize(users.count)}."
  end
end
