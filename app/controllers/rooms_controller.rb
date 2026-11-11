class RoomsController < ApplicationController
  before_action :set_rooms, only: :show

  # There's a single room for now, so land straight in it.
  def index
    redirect_to Room.general
  end

  # Messages are posted over the websocket (see ChatChannel), so this only renders the room.
  def show
    @room = @rooms.find(params[:id])
    @messages = @room.messages.recent
  end

  private
    def set_rooms
      @rooms = Room.alphabetical
    end
end
