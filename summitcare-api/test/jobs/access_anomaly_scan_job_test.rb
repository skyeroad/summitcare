require "test_helper"

class AccessAnomalyScanJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper # assert_enqueued_emails; ActiveJob::TestCase doesn't include it

  test "flags a clinician who views more patients than the hourly threshold" do
    clinician = users(:dr_okafor)
    Current.set(user: clinician) do
      travel_to Time.utc(2026, 10, 5, 15, 20) do
        41.times { |i| AuditLog.record!(action: "view", subject: Patient.new(id: 9_000 + i)) }
      end
    end

    assert_enqueued_emails 1 do
      AccessAnomalyScanJob.perform_now(window_end: Time.utc(2026, 10, 5, 16))
    end
    finding = AnomalyFinding.find_by!(kind: "bulk_access", actor_id: clinician.id)
    assert_equal 41, finding.details["distinct_patients"]
  end
end
