require "test_helper"

class Api::V1::LabResultsControllerTest < ActionDispatch::IntegrationTest
  test "viewing a lab result records who, what, and where without PHI" do
    result = lab_results(:avery_a1c)
    assert_difference -> { AuditEvent.count }, 1 do
      get api_v1_patient_lab_result_path(result.patient, result),
          headers: auth_headers_for(users(:dr_okafor))
    end
    event = AuditEvent.last
    assert_equal ["view", "clinician", result.patient_id, "LabResult"],
                 [event.action, event.actor_role, event.patient_id, event.subject_type]
    assert event.request_id.present?
    refute_match(/Avery|Quinn|SC-100231/, event.attributes.to_json)
  end

  test "the database rejects changes to audit events" do
    event = AuditLog.record!(action: "view", subject: patients(:avery))
    assert_raises(ActiveRecord::ReadOnlyRecord) { event.update!(action: "list") }
    assert_raises(ActiveRecord::StatementInvalid) do
      AuditEvent.where(id: event.id).update_all(action: "list")
    end
  end
end
