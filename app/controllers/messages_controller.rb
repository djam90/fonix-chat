class MessagesController < ApplicationController
  # Messages are posted over the websocket (see ChatChannel), so this only renders the room.
  def index
    @messages = Message.recent
  end
end
