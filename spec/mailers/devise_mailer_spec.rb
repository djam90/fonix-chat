require "rails_helper"

RSpec.describe Devise::Mailer do
  describe "#confirmation_instructions" do
    let(:user) { create(:user, :unconfirmed) }
    let(:mail) { described_class.confirmation_instructions(user, user.confirmation_token) }

    it "sends the user a link to confirm their email address" do
      expect(mail.to).to eq([ user.email ])
      expect(mail.from).to eq([ "no-reply@fonix-chat.test" ])
      expect(mail.body.to_s).to include("Welcome to Fonix Chat!")
      expect(mail.body.to_s).to include("http://example.com/users/confirmation?confirmation_token=#{user.confirmation_token}")
    end
  end
end
