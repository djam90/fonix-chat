require "rails_helper"

RSpec.describe "Signing up", js: true do
  it "requires confirming the email address before chatting" do
    visit new_user_registration_path
    fill_in "Email address", with: "newbie@example.com"
    fill_in "Password", with: "password123"
    fill_in "Confirm password", with: "password123"
    click_on "Create account"

    expect(page).to have_text("A message with a confirmation link has been sent to your email address.")

    user = User.find_by!(email: "newbie@example.com")
    visit user_confirmation_path(confirmation_token: user.confirmation_token)
    expect(page).to have_text("Your email address has been successfully confirmed.")

    sign_in_as user
    expect(page).to have_link("newbie@example.com")
  end
end
