require "rails_helper"

RSpec.describe ChatChannel do
  let(:user) { create(:user) }
  let(:room) { create(:room) }

  before { stub_connection current_user: user }

  it "streams the requested room" do
    subscribe room_id: room.id

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(room)
  end

  it "rejects a room that doesn't exist" do
    subscribe room_id: 0

    expect(subscription).to be_rejected
  end

  it "creates a message in the room and broadcasts it to that room when speaking" do
    subscribe room_id: room.id

    expect {
      perform :speak, body: "Hello over the websocket"
    }.to change(room.messages.where(user: user), :count).by(1)
      .and have_broadcasted_to(room).from_channel(described_class)
  end

  it "transmits validation errors back to the sender only" do
    subscribe room_id: room.id

    expect {
      perform :speak, body: "   "
    }.to not_change(Message, :count)
      .and not_have_broadcasted_to(room).from_channel(described_class)

    expect(transmissions.last).to eq("error" => "Body can't be blank")
  end
end
