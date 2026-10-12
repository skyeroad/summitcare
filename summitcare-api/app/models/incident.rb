class Incident < ApplicationRecord
  RISK_FACTORS = %w[nature_and_extent unauthorized_recipient acquired_or_viewed mitigation].freeze

  belongs_to :reported_by, class_name: "User"
  has_many :incident_affected_patients, dependent: :restrict_with_error

  enum :status, { open: "open", contained: "contained", assessing: "assessing", closed: "closed" }, validate: true
  enum :breach_determination, { pending: "pending", not_breach_exception: "not_breach_exception",
    not_breach_secured: "not_breach_secured", not_breach_low_probability: "not_breach_low_probability",
    breach: "breach" }, prefix: :determination, validate: true

  validate :risk_assessment_complete, if: -> { determination_not_breach_low_probability? || determination_breach? }
  before_save :set_notification_deadline, if: :will_save_change_to_discovered_at?

  def hhs_annual_log_due_on = discovered_at && Date.new(discovered_at.year, 12, 31) + 60

  private

  def risk_assessment_complete
    missing = RISK_FACTORS.reject { |factor| risk_assessment.dig(factor, "finding").present? }
    errors.add(:risk_assessment, "is missing findings for #{missing.to_sentence}") if missing.any?
    errors.add(:risk_assessment, "needs counsel_reviewed_by") if risk_assessment["counsel_reviewed_by"].blank?
  end

  def set_notification_deadline
    self.notification_deadline = discovered_at && discovered_at.to_date + 60
  end
end
