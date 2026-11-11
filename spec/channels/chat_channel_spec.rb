require "rails_helper"

RSpec.describe ChatChannel do
  let(:user) { create(:user) }

  before { stub_connection current_user: user }

  it "subscribes to the chat room stream" do
    subscribe

    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from(Message::STREAM)
  end

  it "creates a message from the current user and broadcasts it when speaking" do
    subscribe

    expect {
      perform :speak, body: "Hello over the websocket"
    }.to change(user.messages, :count).by(1)
      .and have_broadcasted_to(Message::STREAM)

    expect(Message.last.body).to eq("Hello over the websocket")
  end

  it "transmits validation errors back to the sender only" do
    subscribe

    expect {
      perform :speak, body: "   "
    }.to not_change(Message, :count)
      .and not_have_broadcasted_to(Message::STREAM)

    expect(transmissions.last).to eq("error" => "Body can't be blank")
  end
end
