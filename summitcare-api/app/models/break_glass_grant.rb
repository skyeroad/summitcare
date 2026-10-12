class BreakGlassGrant < ApplicationRecord
  DURATION = 2.hours

  belongs_to :user
  belongs_to :patient
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :review_outcome, { justified: "justified", not_justified: "not_justified" }

  validates :reason, presence: true, length: { minimum: 20 }
  scope :active, -> { where("granted_at <= :now AND expires_at > :now", now: Time.current) }
  scope :awaiting_review, -> { where(reviewed_at: nil) }

  def self.open!(user:, patient:, reason:)
    now = Time.current
    create!(user:, patient:, reason:, granted_at: now, expires_at: now + DURATION)
  end

  def review!(reviewer:, outcome:)
    raise ArgumentError, "reviewer must be a compliance officer" unless reviewer.compliance_officer?
    update!(reviewed_by: reviewer, reviewed_at: Time.current, review_outcome: outcome)
  end
end
