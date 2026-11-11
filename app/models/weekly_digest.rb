# Stats for the weekly summary email sent to each user.
class WeeklyDigest
  attr_reader :user, :period_end, :period_start

  def initialize(user, period_end: Time.current)
    @user = user
    @period_end = period_end
    @period_start = period_end - 1.week
  end

  # Every message posted in the room during the last week.
  def exchanged_last_week
    @exchanged_last_week ||= last_week.count
  end

  def sent_last_week
    @sent_last_week ||= last_week.where(user: user).count
  end

  def received_last_week
    @received_last_week ||= last_week.not_from(user).count
  end

  def last_message_at
    return @last_message_at if defined?(@last_message_at)
    @last_message_at = user.messages.where(created_at: ..period_end).maximum(:created_at)
  end

  # Messages from other users since the user last posted. If they have never posted,
  # count everything since they joined.
  def received_since_last_message
    @received_since_last_message ||= Message.not_from(user)
      .where("messages.created_at > ? AND messages.created_at <= ?", last_message_at || user.created_at, period_end)
      .count
  end

  private
    def last_week
      Message.where(created_at: period_start..period_end)
    end
end
