require "rails_helper"

RSpec.describe DigestMailer do
  describe "#weekly" do
    let(:alice) { create(:user) }
    let(:bob) { create(:user) }

    it "summarises the last week and the messages since the user's last post" do
      travel_to Time.zone.parse("2026-02-07 09:00") do
        create(:message, user: alice, created_at: Time.zone.parse("2026-02-01 12:00"))
        create_list(:message, 3, user: bob, created_at: 2.days.ago)

        mail = described_class.weekly(alice)
        text = mail.text_part.body.to_s

        expect(mail.subject).to eq("Your weekly Fonix Chat summary")
        expect(mail.to).to eq([ alice.email ])
        expect(text).to include("4 messages have been exchanged in the last week.")
        expect(text).to include("You sent 1 and received 3.")
        expect(text).to include("3 since your last message on the 1st of February.")
        expect(mail.html_part.body.to_s).to include("3 since your last message on the 1st of February.")
      end
    end

    it "handles a user who has never posted" do
      bob
      create(:message, user: alice)

      text = described_class.weekly(bob).text_part.body.to_s

      expect(text).to include("1 message has been exchanged in the last week.")
      expect(text).to include("1 message since you joined.")
    end
  end
end
