require "rails_helper"

RSpec.describe Message do
  let(:user) { create(:user, email: "sender@example.com") }

  it "strips the body and requires it to be present" do
    expect(described_class.new(body: "  hello \n").body).to eq("hello")
    expect(build(:message, body: "   ")).not_to be_valid
  end

  it "limits the body length" do
    expect(build(:message, body: "a" * (Message::MAX_LENGTH + 1))).not_to be_valid
    expect(build(:message, body: "a" * Message::MAX_LENGTH)).to be_valid
  end

  it "broadcasts the rendered, escaped message to the chat room once created" do
    message = nil

    expect {
      message = create(:message, user: user, body: "Hello <b>world</b>")
    }.to have_broadcasted_to(Message::STREAM).with { |data|
      expect(data["id"]).to eq(message.id)
      expect(data["html"]).to include(%(id="message_#{message.id}"), "sender@example.com", "Hello &lt;b&gt;world&lt;/b&gt;")
    }
  end

  describe ".recent" do
    it "returns the latest messages in chronological order" do
      first = create(:message, created_at: 3.minutes.ago)
      second = create(:message, created_at: 2.minutes.ago)
      third = create(:message, created_at: 1.minute.ago)

      expect(described_class.recent(2)).to eq([ second, third ])
      expect(described_class.recent).to eq([ first, second, third ])
    end
  end
end
