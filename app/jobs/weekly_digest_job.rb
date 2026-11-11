class WeeklyDigestJob < ApplicationJob
  queue_as :default

  def perform(period_end: Time.current)
    User.confirmed.find_each do |user|
      DigestMailer.weekly(user, period_end: period_end).deliver_later
    end
  end
end
