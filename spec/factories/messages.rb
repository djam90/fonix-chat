FactoryBot.define do
  factory :message do
    room
    user
    sequence(:body) { |n| "Message #{n}" }
  end
end
