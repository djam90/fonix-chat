require "capybara/rspec"

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument "--headless=new"
  options.add_argument "--window-size=1400,900"
  # Incognito keeps Chrome's password manager out of the way. Otherwise it saves the
  # password from the sign up form and swallows typing into the next password field.
  options.add_argument "--incognito"

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :headless_chrome
Capybara.server = :puma, { Silent: true }
