class AmendmentNotificationJob < ApplicationJob
  def perform(amendment_request)
    patient = amendment_request.patient
    since = amendment_request.target.created_at
    prior_recipients = patient.disclosures.where(disclosed_at: since..).distinct.pluck(:recipient_name)

    ComplianceMailer.amendment_recipients(
      amendment_request,
      named_by_patient: Array(amendment_request.notify_recipients),
      prior_recipients:
    ).deliver_later
  end
end
