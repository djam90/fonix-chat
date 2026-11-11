require "rails_helper"

# Devise is tested upstream, so these cover how it is configured for this app.
RSpec.describe "Authentication" do
  describe "signing up" do
    def sign_up(email:, password: "password123", password_confirmation: password)
      post user_registration_path, params: { user: { email:, password:, password_confirmation: } }
    end

    it "creates an unconfirmed user, emails a confirmation link and does not sign them in" do
      expect { sign_up(email: "New@Example.com") }
        .to change(User, :count).by(1)
        .and have_enqueued_mail(Devise::Mailer, :confirmation_instructions)

      expect(User.find_by!(email: "new@example.com")).not_to be_confirmed
      expect(response).to redirect_to(new_user_session_path)
      follow_redirect!
      expect(response.body).to include("A message with a confirmation link has been sent to your email address.")
    end

    it "rejects an invalid email address" do
      expect { sign_up(email: "not-an-email") }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Email is invalid")
    end

    it "rejects a short password" do
      expect { sign_up(email: "new@example.com", password: "short") }.not_to change(User, :count)

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Password is too short")
    end
  end

  describe "confirming an email address" do
    it "confirms the user and asks them to sign in" do
      user = create(:user, :unconfirmed)

      get user_confirmation_path(confirmation_token: user.confirmation_token)

      expect(user.reload).to be_confirmed
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "signing in" do
    def sign_in_with(user, password: "password123")
      post user_session_path, params: { user: { email: user.email, password: password } }
    end

    it "lets a confirmed user into the chat" do
      sign_in_with create(:user)

      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response).to have_http_status(:ok)
    end

    it "turns away an unconfirmed user" do
      sign_in_with create(:user, :unconfirmed)

      expect(response).to redirect_to(new_user_session_path)
      follow_redirect!
      expect(response.body).to include("You have to confirm your email address before continuing.")
    end

    it "rejects a wrong password" do
      sign_in_with create(:user), password: "wrong-password"

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include("Invalid email or password.")
    end
  end

  describe "resetting a password" do
    it "emails reset instructions without revealing whether the account exists" do
      user = create(:user)

      expect {
        post user_password_path, params: { user: { email: user.email } }
      }.to have_enqueued_mail(Devise::Mailer, :reset_password_instructions)
      known_response = response.location

      expect {
        post user_password_path, params: { user: { email: "nobody@example.com" } }
      }.not_to have_enqueued_mail

      expect(response.location).to eq(known_response)
    end
  end

  it "signs out" do
    sign_in create(:user)

    delete destroy_user_session_path
    get root_path

    expect(response).to redirect_to(new_user_session_path)
  end
end
