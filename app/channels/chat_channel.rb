class ChatChannel < ApplicationCable::Channel
  def subscribed
    @room = Room.find_by(id: params[:room_id])

    if @room
      stream_for @room
    else
      reject
    end
  end

  def speak(data)
    message = current_user.messages.build(room: @room, body: data["body"])

    unless message.save
      transmit({ error: message.errors.full_messages.to_sentence })
    end
  end
end
