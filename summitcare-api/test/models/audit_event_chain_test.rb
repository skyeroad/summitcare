require "test_helper"

class AuditEventChainTest < ActiveSupport::TestCase
  test "each event links to the previous digest and survives a reload" do
    first = AuditLog.record!(action: "view", subject: patients(:avery))
    second = AuditLog.record!(action: "list", subject: LabResult, metadata: { record_ids: [3, 1] })

    assert_equal first.digest, second.previous_digest
    assert_equal second.digest, second.reload.compute_digest(second.previous_digest)
  end

  test "a changed field no longer matches its digest" do
    event = AuditLog.record!(action: "view", subject: patients(:avery))
    event.actor_role = "admin" # in memory only; the database would refuse
    refute_equal event.digest, event.compute_digest(event.previous_digest)
  end

  # Not in the book: a Time in metadata (RetentionPurgeJob trigger:, Solution 29)
  # must hash the same before and after jsonb turns it into a string.
  test "metadata with a timestamp survives a reload" do
    event = AuditLog.record!(action: "delete", subject: messages(:avery_question),
                             metadata: { trigger: Time.current, legal_basis: "test" })
    assert_equal event.digest, event.reload.compute_digest(event.previous_digest)
  end

  test "the verification job walks the chain and records a control run" do
    3.times { AuditLog.record!(action: "view", subject: patients(:avery)) }
    AuditChainVerificationJob.perform_now
    assert ControlRun.where(control: "audit_chain_verification").last.succeeded
  end
end
