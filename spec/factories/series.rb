FactoryBot.define do
  factory :series do
    sequence(:name) { |n| "シリーズ#{n}" }
    association :user
  end
end
