module DigestMailerHelper
  # "1st of February", with the year added when it isn't the current one.
  def digest_date(time)
    date = time.to_date
    formatted = "#{date.day.ordinalize} of #{date.strftime("%B")}"
    date.year == Date.current.year ? formatted : "#{formatted} #{date.year}"
  end

  def messages_count(count)
    pluralize(number_with_delimiter(count), "message")
  end

  def since_last_message_line(digest)
    if digest.last_message_at
      "#{number_with_delimiter(digest.received_since_last_message)} since your last message on the #{digest_date(digest.last_message_at)}."
    else
      "#{messages_count(digest.received_since_last_message)} since you joined. You haven't posted yet, come and say hello!"
    end
  end
end
