# Output of AccessAnomalyScanJob, reviewed weekly by the compliance officer (Solution 17).
class AnomalyFinding < ApplicationRecord
  DISPOSITIONS = %w[expected coached escalated_to_incident].freeze

  belongs_to :reviewed_by, class_name: "User", optional: true
  validates :disposition, inclusion: { in: DISPOSITIONS }, allow_nil: true
  scope :open, -> { where(status: "open") }
end
