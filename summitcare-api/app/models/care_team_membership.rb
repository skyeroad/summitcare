class CareTeamMembership < ApplicationRecord
  belongs_to :patient
  belongs_to :user

  # ends_on is exclusive: ending a membership today removes access today.
  scope :current, -> {
    where("starts_on <= :today AND (ends_on IS NULL OR ends_on > :today)", today: Date.current)
  }
end
