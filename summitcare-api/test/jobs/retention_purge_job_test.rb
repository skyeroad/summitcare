require "test_helper"

class RetentionPurgeJobTest < ActiveJob::TestCase
  test "purges expired records, honors legal holds, and audits disposal" do
    expired = Message.create!(patient: patients(:avery), sender: users(:dr_okafor), body: "Old", created_at: 11.years.ago)
    held = Message.create!(patient: patients(:jordan), sender: users(:dr_okafor), body: "Old", created_at: 11.years.ago)
    LegalHold.create!(patient: patients(:jordan), reason: "Records subpoena", placed_by: users(:morgan_reyes), placed_at: 1.day.ago)

    RetentionPurgeJob.perform_now("dry_run")
    assert Message.exists?(expired.id)

    RetentionPurgeJob.perform_now("execute")
    assert_not Message.exists?(expired.id)
    assert Message.exists?(held.id)
    assert AuditEvent.exists?(action: "delete", subject_type: "Message", subject_id: expired.id)
  end

  # Not in the book: the hash chain still verifies after a purge, including the
  # Time stored in the delete event's metadata.
  test "the audit chain verifies after a purge" do
    Message.create!(patient: patients(:avery), sender: users(:dr_okafor), body: "Old", created_at: 11.years.ago)
    RetentionPurgeJob.perform_now("execute")
    AuditChainVerificationJob.perform_now
    assert ControlRun.where(control: "audit_chain_verification").last.succeeded
  end
end
