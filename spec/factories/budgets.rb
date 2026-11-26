FactoryBot.define do
  factory :budget do
    user
    month { Date.current.beginning_of_month }
    amount { 1000 }
  end
end
