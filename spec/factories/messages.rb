FactoryBot.define do
  factory :message do
    user
    sequence(:body) { |n| "Message #{n}" }
  end
end
