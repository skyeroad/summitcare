require "test_helper"

class AmendmentRequestTest < ActiveSupport::TestCase
  test "accepting appends an amendment and leaves the original value intact" do
    lab = lab_results(:riley_cbc)
    original = lab.notes
    request = lab.patient.amendment_requests.create!(target: lab, requested_change: "Medication is lisinopril")

    request.accept!(by: users(:dr_okafor), amendment_text: "Corrected medication: lisinopril")

    assert_equal original, lab.reload.notes
    assert_equal ["amendment"], lab.record_amendments.pluck(:kind)
    assert_raises(ActiveRecord::ReadOnlyRecord) { lab.record_amendments.first.update!(body: "x") }
  end
end
