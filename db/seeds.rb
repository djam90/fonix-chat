# Demo data for local development: bin/rails db:seed
alice = User.find_or_create_by!(email: "alice@example.com") do |user|
  user.password = "password123"
  user.skip_confirmation!
end

bob = User.find_or_create_by!(email: "bob@example.com") do |user|
  user.password = "password123"
  user.skip_confirmation!
end

if Message.none?
  alice.messages.create!(body: "Hi Bob, welcome to Fonix Chat!", created_at: 2.days.ago)
  bob.messages.create!(body: "Thanks Alice, this is great.", created_at: 2.days.ago + 5.minutes)
  alice.messages.create!(body: "Messages here are sent over websockets, so they show up instantly.", created_at: 1.day.ago)
end
