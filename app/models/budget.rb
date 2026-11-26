class Budget < ApplicationRecord
    belongs_to :user

    validates :month, presence: true, uniqueness: { scope: :user_id }
    validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    def month=(value)
      if value.is_a?(String) && value.match?(/\A\d{4}-\d{2}\z/)
       value = Date.strptime(value, "%Y-%m")
      end
      value = value.beginning_of_month if value.respond_to?(:beginning_of_month)
      super(value)
    end
end
