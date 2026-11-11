FactoryBot.define do
  factory :room do
    sequence(:name) { |n| "room-#{n}" }
  end
end
