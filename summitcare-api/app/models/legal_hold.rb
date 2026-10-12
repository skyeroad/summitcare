# Counsel places a hold; nothing for that patient is purged until it is released (Solution 29).
class LegalHold < ApplicationRecord
  belongs_to :patient
  belongs_to :placed_by, class_name: "User"

  validates :reason, :placed_at, presence: true
  scope :active, -> { where(released_at: nil) }
end
