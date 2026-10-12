class AmendmentRequest < ApplicationRecord
  include ProtectedHealthInformation
  phi_attributes :requested_change, :reason

  RESPONSE_DAYS = 60
  EXTENSION_DAYS = 30
  DENIAL_BASES = %w[not_created_by_us not_in_designated_record_set
                    not_available_for_inspection accurate_and_complete].freeze

  belongs_to :patient
  belongs_to :target, polymorphic: true
  belongs_to :decided_by, class_name: "User", optional: true
  has_many :record_amendments, dependent: :restrict_with_exception

  enum :status, { submitted: "submitted", under_review: "under_review",
                  accepted: "accepted", denied: "denied" }, default: "submitted"

  validates :requested_change, presence: true
  validates :denial_basis, inclusion: { in: DENIAL_BASES }, if: :denied?
  before_validation(on: :create) { self.due_on ||= Date.current + RESPONSE_DAYS }

  scope :outstanding, -> { where(status: %w[submitted under_review]) }

  def effective_due_on = extended_due_on || due_on

  def extend!(reason:)
    raise ArgumentError, "already extended" if extended_due_on
    raise ArgumentError, "original due date has passed" if Date.current > due_on
    update!(extended_due_on: due_on + EXTENSION_DAYS)
  end

  # True when the patient filed a statement of disagreement, or asked for the
  # request and denial to travel with the record (§164.526(d)).
  def include_with_disclosures?
    super || record_amendments.exists?(kind: "disagreement")
  end

  def accept!(by:, amendment_text:)
    transaction do
      update!(status: "accepted", decided_by: by, decided_at: Time.current)
      record_amendments.create!(target:, kind: "amendment", body: amendment_text, author: by)
      AuditLog.record!(action: "update", subject: target, patient:,
                       reason: "amendment_accepted", metadata: { amendment_request_id: id })
    end
    AmendmentNotificationJob.perform_later(self)
  end

  def deny!(by:, basis:, explanation:)
    transaction do
      update!(status: "denied", decided_by: by, decided_at: Time.current, denial_basis: basis)
      record_amendments.create!(target:, kind: "denial", body: explanation, author: by)
    end
    AmendmentMailer.denial(self).deliver_later
  end
end
