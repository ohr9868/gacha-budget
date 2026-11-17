class Series < ApplicationRecord
    belongs_to :user
    has_many :records, dependent: :restrict_with_error
    validates :name, presence: true, length: { maximum: 30 }, uniqueness: { scope: :user_id }
end
