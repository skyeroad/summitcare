require "test_helper"

class IncidentTest < ActiveSupport::TestCase
  test "computes the 60-day deadline and requires a full risk assessment" do
    incident = Incident.create!(summary: "Lost staff laptop", reported_by: users(:morgan_reyes), status: "assessing",
                                phi_involved: true, breach_determination: "pending",
                                detected_at: Time.zone.parse("2026-03-02 09:00"),
                                discovered_at: Time.zone.parse("2026-03-02 09:00"))
    assert_equal Date.new(2026, 5, 1), incident.notification_deadline

    incident.breach_determination = "not_breach_low_probability"
    incident.risk_assessment = { "nature_and_extent" => { "finding" => "Names and appointment dates" } }
    assert_not incident.valid?
    assert_match "unauthorized_recipient", incident.errors[:risk_assessment].join
  end
end
