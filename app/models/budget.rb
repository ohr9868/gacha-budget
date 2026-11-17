class Budget < ApplicationRecord
    belongs_to :user
    before_validation :beginning_of_month

    validates :month, presence: true, uniqueness: { scope: :user_id }
    validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    private

    def beginning_of_month
        self.month = month.beginning_of_month if month.present?
    end
end
