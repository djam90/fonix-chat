require "rails_helper"

RSpec.describe WeeklyDigest do
  let(:now) { Time.current.change(usec: 0) }
  let(:alice) { create(:user, created_at: 1.month.ago) }
  let(:bob) { create(:user, created_at: 1.month.ago) }

  def post(user, at:)
    create(:message, user: user, created_at: at)
  end

  it "counts messages exchanged, sent and received in the last week" do
    post alice, at: now - 8.days
    post alice, at: now - 6.days
    post bob, at: now - 5.days
    post bob, at: now - 1.day

    digest = described_class.new(alice, period_end: now)

    expect(digest.exchanged_last_week).to eq(3)
    expect(digest.sent_last_week).to eq(1)
    expect(digest.received_last_week).to eq(2)
  end

  it "counts messages received since the user's last message, even beyond the last week" do
    post bob, at: now - 20.days
    post alice, at: now - 14.days
    post bob, at: now - 10.days
    post bob, at: now - 2.days
    post alice, at: now + 1.hour

    digest = described_class.new(alice, period_end: now)

    expect(digest.last_message_at).to eq(now - 14.days)
    expect(digest.received_since_last_message).to eq(2)
  end

  it "counts messages since joining when the user has never posted" do
    post alice, at: bob.created_at - 1.day
    post alice, at: now - 1.day

    digest = described_class.new(bob, period_end: now)

    expect(digest.last_message_at).to be_nil
    expect(digest.received_since_last_message).to eq(1)
  end
end
