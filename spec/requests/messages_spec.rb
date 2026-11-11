require "rails_helper"

RSpec.describe "Messages" do
  it "requires authentication" do
    get root_path

    expect(response).to redirect_to(new_user_session_path)
  end

  it "shows the chat room with recent messages, marking the viewer's own" do
    user = create(:user)
    create(:message, body: "Hello from someone else")
    create(:message, user: user, body: "Hello from me")
    sign_in user

    get root_path

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    expect(page.css("[data-controller=chat]")).to be_present
    expect(page.css(".message").size).to eq(2)
    expect(page.css(".message--own .message__body").map(&:text)).to eq([ "Hello from me" ])
  end
end
