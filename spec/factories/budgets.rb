FactoryBot.define do
  factory :budget do
    user
    month { Date.new(2026, 11, 1) }
    amount { 1000 }
  end
end
