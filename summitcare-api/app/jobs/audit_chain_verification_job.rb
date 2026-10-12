class AuditChainVerificationJob < ApplicationJob
  def perform
    previous = AuditEvent::GENESIS
    AuditEvent.find_each do |event| # walks in primary-key order
      unless event.previous_digest == previous && event.digest == event.compute_digest(previous)
        ComplianceMailer.audit_chain_broken(event.id).deliver_later
        Rails.logger.error(event: "audit_chain_broken", audit_event_id: event.id)
        return record_run(false, audit_event_id: event.id)
      end
      previous = event.digest
    end
    record_run(true)
  end

  private

  def record_run(succeeded, **details) # read by the evidence pack (Solution 35)
    ControlRun.create!(control: "audit_chain_verification", succeeded:, ran_at: Time.current, details:)
  end
end
