class Record < ApplicationRecord
    belongs_to :series
    validates :played_date, presence: true
    validates :price_per_play, presence: true, numericality: { only_integer: true, greater_than: 0 }
    validates :play_count, presence: true, numericality: { only_integer: true, greater_than: 0 }
    def total_price
      price_per_play * play_count
    end
end
