require "test_helper"

class BreakGlassTest < ActionDispatch::IntegrationTest
  setup { @headers = auth_headers_for(users(:dr_okafor)) }

  test "a grant opens time-boxed, audited access" do
    jordan = patients(:jordan)
    get api_v1_patient_path(jordan), headers: @headers
    assert_response :not_found

    post api_v1_break_glass_grants_path, headers: @headers, as: :json,
         params: { mrn: jordan.mrn, reason: "Covering overnight; patient called about severe reaction" }
    grant_id = response.parsed_body["id"]

    get api_v1_patient_path(jordan), headers: @headers
    assert_response :success
    assert AuditEvent.where("metadata->>'break_glass_grant_id' = ?", grant_id.to_s).exists?

    travel BreakGlassGrant::DURATION + 1.minute
    get api_v1_patient_path(jordan), headers: auth_headers_for(users(:dr_okafor))
    assert_response :not_found
  end
end
