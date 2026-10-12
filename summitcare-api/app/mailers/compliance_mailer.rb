class ComplianceMailer < ApplicationMailer
  CONSOLE = "https://summitcare.example/console"

  # Every ComplianceMailer method takes IDs, counts, or records and sends a console link,
  # never PHI: audit_chain_broken (Solution 14), record_request_due and
  # record_request_overdue (Solution 18), amendment_recipients (Solution 20).
  def findings_ready(count)
    @count = count
    @url = "#{CONSOLE}/anomaly_findings"
    mail to: compliance_officers, subject: "SummitCare: #{count} new access findings to review"
  end

  def audit_chain_broken(audit_event_id)
    @audit_event_id = audit_event_id
    @url = "#{CONSOLE}/audit_events/#{audit_event_id}"
    mail to: compliance_officers, subject: "SummitCare: audit chain verification failed"
  end

  def record_request_due(record_request, days_left:)
    @record_request_id = record_request.id
    @days_left = days_left
    @due_on = record_request.effective_due_on
    @url = "#{CONSOLE}/record_requests/#{record_request.id}"
    mail to: compliance_officers, subject: "SummitCare: record request #{record_request.id} due in #{days_left} days"
  end

  def record_request_overdue(record_request)
    @record_request_id = record_request.id
    @due_on = record_request.effective_due_on
    @url = "#{CONSOLE}/record_requests/#{record_request.id}"
    mail to: compliance_officers, subject: "SummitCare: record request #{record_request.id} is overdue"
  end

  def amendment_recipients(amendment_request, named_by_patient:, prior_recipients:)
    @amendment_request_id = amendment_request.id
    @recipient_count = (named_by_patient + prior_recipients).uniq.size
    @url = "#{CONSOLE}/amendment_requests/#{amendment_request.id}"
    mail to: compliance_officers,
         subject: "SummitCare: amendment #{amendment_request.id} accepted, #{@recipient_count} recipients to notify"
  end

  private

  def compliance_officers = User.compliance_officer.where(deactivated_at: nil).pluck(:email_address)
end
