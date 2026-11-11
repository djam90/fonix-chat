module FeatureAuthenticationHelpers
  def sign_in_as(user, password: "password123")
    visit new_user_session_path
    fill_in "Email address", with: user.email
    fill_in "Password", with: password
    click_on "Sign in"
    expect(page).to have_css(".chat__status", text: "Connected")
  end
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include FeatureAuthenticationHelpers, type: :feature
end
