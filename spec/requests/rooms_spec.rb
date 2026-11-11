require "rails_helper"

RSpec.describe "Rooms" do
  let(:user) { create(:user) }

  it "requires authentication" do
    get root_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "lands in #general, creating it if needed" do
    sign_in user

    get root_path

    expect(response).to redirect_to(room_path(Room.find_by!(name: "general")))
  end

  it "shows the room's recent messages, marking the viewer's own, and the list of rooms" do
    room = create(:room, name: "general")
    random = create(:room, name: "random")
    create(:message, room: room, body: "Hello from someone else")
    create(:message, room: room, user: user, body: "Hello from me")
    create(:message, room: random, body: "In another room")
    sign_in user

    get room_path(room)

    page = Nokogiri::HTML(response.body)
    expect(page.css("[data-controller=chat]").first["data-chat-room-id-value"]).to eq(room.id.to_s)
    expect(page.css(".message").size).to eq(2)
    expect(page.css(".message--own .message__body").map(&:text)).to eq([ "Hello from me" ])
    expect(page.css(".rooms__link").map(&:text)).to eq([ "# general", "# random" ])
    expect(page.css(".rooms__link--current").map(&:text)).to eq([ "# general" ])
  end
end
