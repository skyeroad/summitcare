require "test_helper"

class RecordRequestTest < ActiveSupport::TestCase
  test "due 30 days after receipt, extendable once by 30 days" do
    travel_to Time.zone.local(2026, 10, 1, 9) do
      record_request = patients(:avery).record_requests.create!(format: "both")
      assert_equal Date.new(2026, 10, 31), record_request.due_on

      record_request.extend!(reason: "Older records are archived off-site")
      assert_equal Date.new(2026, 11, 30), record_request.effective_due_on
      assert_raises(ArgumentError) { record_request.extend!(reason: "again") }
    end
  end
end
