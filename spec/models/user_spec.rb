require "rails_helper"

RSpec.describe User do
  describe "email" do
    it "is downcased and stripped" do
      user = create(:user, email: " DOWNCASED@EXAMPLE.COM ")

      expect(user.email).to eq("downcased@example.com")
    end

    it "must be a valid email address" do
      [ nil, "", "not-an-email", "missing-at.example.com", "two@@example.com" ].each do |email|
        user = build(:user, email: email)

        expect(user).not_to be_valid, "expected #{email.inspect} to be invalid"
        expect(user.errors[:email]).to be_present
      end

      expect(build(:user, email: "new.user+chat@example.co.uk")).to be_valid
    end

    it "must be unique regardless of case" do
      create(:user, email: "taken@example.com")
      user = build(:user, email: "TAKEN@example.com")

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("has already been taken")
    end
  end

  it "requires a password of at least 8 characters" do
    user = build(:user, password: "short")

    expect(user).not_to be_valid
    expect(user.errors[:password]).to be_present
  end

  describe "email confirmation" do
    it "emails a confirmation link on sign up" do
      expect { create(:user, :unconfirmed) }
        .to have_enqueued_mail(Devise::Mailer, :confirmation_instructions)
    end

    it "blocks sign in until the email address is confirmed" do
      user = create(:user, :unconfirmed)
      expect(user).not_to be_active_for_authentication

      user.confirm

      expect(user).to be_active_for_authentication
    end

    it "expires the confirmation link after 2 days" do
      user = create(:user, :unconfirmed)

      travel 2.days + 1.minute do
        confirmed = described_class.confirm_by_token(user.confirmation_token)

        expect(confirmed).not_to be_confirmed
        expect(confirmed.errors[:email].join).to include("needs to be confirmed within 2 days")
      end
    end
  end

  describe ".confirmed" do
    it "excludes unconfirmed users" do
      confirmed = create(:user)
      unconfirmed = create(:user, :unconfirmed)

      expect(described_class.confirmed).to include(confirmed)
      expect(described_class.confirmed).not_to include(unconfirmed)
    end
  end
end
