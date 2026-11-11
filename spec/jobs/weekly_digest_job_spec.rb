require "rails_helper"

RSpec.describe WeeklyDigestJob do
  before { ActionMailer::Base.deliveries.clear }

  it "emails every confirmed user and skips unconfirmed ones" do
    alice = create(:user)
    bob = create(:user)
    create(:user, :unconfirmed)

    perform_enqueued_jobs { described_class.perform_now }

    recipients = ActionMailer::Base.deliveries.flat_map(&:to)
    expect(recipients).to contain_exactly(alice.email, bob.email)
  end
end
