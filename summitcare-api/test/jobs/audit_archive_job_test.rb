require "test_helper"

# Not in the book: the archive upload, against a stubbed S3 client (no network).
class AuditArchiveJobTest < ActiveJob::TestCase
  test "uploads the day's events as JSON lines with the last digest" do
    day = Date.new(2026, 10, 11)
    travel_to(Time.utc(2026, 10, 11, 12)) { 2.times { AuditLog.record!(action: "view", subject: patients(:avery)) } }

    s3 = Aws::S3::Client.new(stub_responses: true)
    with_class_method(Aws::S3::Client, :new, s3) { AuditArchiveJob.perform_now(day) }

    request = s3.api_requests.find { _1[:operation_name] == :put_object }
    assert_equal "audit-events/2026-10-11.jsonl", request[:params][:key]
    assert_equal 2, request[:params][:body].lines.size
    assert_equal AuditEvent.order(:id).last.digest, request[:params][:metadata]["last-digest"]
  end
end
