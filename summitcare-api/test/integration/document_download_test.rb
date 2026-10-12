require "test_helper"

class DocumentDownloadTest < ActionDispatch::IntegrationTest
  test "download is authorized, audited, and short-lived" do
    document = documents(:avery_insurance_card)
    assert_difference -> { AuditEvent.where(action: "download").count }, 1 do
      get api_v1_patient_document_path(document.patient, document),
          headers: auth_headers_for(users(:avery))
    end
    assert_response :success
    assert_operator Time.iso8601(response.parsed_body["expires_at"]), :<=, 61.seconds.from_now
  end

  test "another patient cannot download it" do
    document = documents(:avery_insurance_card)
    get api_v1_patient_document_path(document.patient, document),
        headers: auth_headers_for(users(:jordan))
    assert_response :not_found
  end
end
