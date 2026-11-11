class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from Message::STREAM
  end

  def speak(data)
    message = current_user.messages.build(body: data["body"])

    unless message.save
      transmit({ error: message.errors.full_messages.to_sentence })
    end
  end
end
