require "test_helper"

# Not in the book: Solution 18's deadline reminders.
class RecordRequestDeadlineJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "warns at 10, 5, 2, and 0 days left and flags overdue requests" do
    record_request = patients(:avery).record_requests.create!(format: "pdf", requested_at: Time.zone.local(2026, 10, 1, 9))

    assert_enqueued_email_with ComplianceMailer, :record_request_due, args: [record_request, { days_left: 10 }] do
      RecordRequestDeadlineJob.perform_now(today: Date.new(2026, 10, 21))
    end
    assert_no_enqueued_emails { RecordRequestDeadlineJob.perform_now(today: Date.new(2026, 10, 22)) }
    assert_enqueued_email_with ComplianceMailer, :record_request_overdue, args: [record_request] do
      RecordRequestDeadlineJob.perform_now(today: Date.new(2026, 11, 1))
    end
  end
end
