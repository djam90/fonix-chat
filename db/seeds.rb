# Demo data for local development: bin/rails db:seed
alice = User.find_or_create_by!(email: "alice@example.com") do |user|
  user.password = "password123"
  user.skip_confirmation!
end

bob = User.find_or_create_by!(email: "bob@example.com") do |user|
  user.password = "password123"
  user.skip_confirmation!
end

general = Room.general

if general.messages.none?
  general.messages.create!(user: alice, body: "Hi Bob, welcome to Fonix Chat!", created_at: 2.days.ago)
  general.messages.create!(user: bob, body: "Thanks Alice, this is great.", created_at: 2.days.ago + 5.minutes)
  general.messages.create!(user: alice, body: "Messages here are sent over websockets, so they show up instantly.", created_at: 1.day.ago)
end
