class RecordRequest < ApplicationRecord
  RESPONSE_DAYS = 30
  EXTENSION_DAYS = 30
  FORMATS = %w[fhir_json pdf both paper].freeze

  belongs_to :patient
  has_one_attached :fhir_bundle
  has_one_attached :pdf

  enum :status, { received: "received", in_progress: "in_progress",
                  fulfilled: "fulfilled", denied: "denied" }, default: "received"

  validates :format, inclusion: { in: FORMATS }
  scope :outstanding, -> { where(status: %w[received in_progress]) }

  before_validation(on: :create) do
    self.requested_at ||= Time.current
    self.due_on ||= requested_at.to_date + RESPONSE_DAYS
  end

  def effective_due_on = extended_due_on || due_on

  def extend!(reason:)
    raise ArgumentError, "already extended" if extended_due_on
    raise ArgumentError, "original due date has passed" if Date.current > due_on

    update!(extended_due_on: due_on + EXTENSION_DAYS)
    RecordRequestMailer.extension_notice(self, reason:).deliver_later
  end
end
