FactoryBot.define do
  factory :record do
    played_date { Date.current }
    price_per_play { 300 }
    play_count { 3 }
    association :series
  end
end
