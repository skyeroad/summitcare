# A patient's request for an accounting of disclosures (Solution 19): the same
# clock pattern as RecordRequest, with 60 days to respond.
class AccountingRequest < ApplicationRecord
  RESPONSE_DAYS = 60
  EXTENSION_DAYS = 30

  belongs_to :patient
  enum :status, { received: "received", in_progress: "in_progress",
                  fulfilled: "fulfilled", denied: "denied" }, default: "received"
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
  end

  def report = DisclosureAccounting.new(patient, requested_at:)
end
