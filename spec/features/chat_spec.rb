require "rails_helper"

RSpec.describe "Chat", js: true do
  let(:alice) { create(:user, email: "alice@example.com") }
  let(:bob) { create(:user, email: "bob@example.com") }

  # Headless Chrome on macOS only delivers keyboard and mouse input reliably to the
  # browser that has OS focus, so the secondary browser submits the form via script.
  def send_message_via_script(body)
    find("form.chat__composer").execute_script(<<~JS, body)
      this.querySelector("textarea").value = arguments[0]
      this.requestSubmit()
    JS
  end

  it "delivers messages live to everyone in the room" do
    using_session(:bob) { sign_in_as bob }

    sign_in_as alice
    fill_in "Message", with: "Hello from Alice!"
    click_on "Send"

    expect(page).to have_css(".message--own .message__body", text: "Hello from Alice!")
    expect(page).to have_field("Message", with: "")

    using_session(:bob) do
      expect(page).to have_css(".message:not(.message--own) .message__body", text: "Hello from Alice!")
      expect(page).to have_css(".message__author", text: "alice@example.com")

      send_message_via_script "Hi Alice, Bob here"
      expect(page).to have_css(".message--own .message__body", text: "Hi Alice, Bob here")
    end

    expect(page).to have_css(".message:not(.message--own) .message__body", text: "Hi Alice, Bob here")

    fill_in "Message", with: "Enter sends too"
    find_field("Message").send_keys(:enter)
    expect(page).to have_css(".message--own .message__body", text: "Enter sends too")

    using_session(:bob) do
      expect(page).to have_css(".message:not(.message--own) .message__body", text: "Enter sends too")
    end
  end
end
