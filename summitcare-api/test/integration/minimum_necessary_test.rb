require "test_helper"

# Not in the book: Solution 4's scopes and serializers over HTTP.
class MinimumNecessaryTest < ActionDispatch::IntegrationTest
  test "front desk lists appointments without the visit reason and cannot read lab results" do
    headers = auth_headers_for(users(:pat_lindqvist))
    get api_v1_patient_appointments_path(patients(:avery)), headers: headers
    assert_response :success
    assert_not_includes response.parsed_body.first.keys, "reason"

    get api_v1_patient_lab_results_path(patients(:avery)), headers: headers
    assert_response :success
    assert_empty response.parsed_body
  end

  test "a patient sees only their own chart" do
    headers = auth_headers_for(users(:avery))
    get api_v1_patients_path, headers: headers
    assert_equal [patients(:avery).id], response.parsed_body.map { _1["id"] }

    get api_v1_patient_path(patients(:jordan)), headers: headers
    assert_response :not_found
  end

  test "patients request their records and the export job fulfills and audits it" do
    headers = auth_headers_for(users(:avery))
    assert_enqueued_with(job: RecordExportJob) do
      post api_v1_patient_record_export_path(patients(:avery)), headers: headers, as: :json
    end
    assert_response :accepted
    perform_enqueued_jobs(only: RecordExportJob)
    assert AuditEvent.exists?(action: "export", patient_id: patients(:avery).id)

    get api_v1_patient_record_export_path(patients(:avery), file: "pdf"), headers: headers
    assert_response :success
    assert response.parsed_body["url"].present?
  end
end
