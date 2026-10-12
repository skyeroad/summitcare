require "test_helper"

class PhiLogLeakTest < ActionDispatch::IntegrationTest
  SYNTHETIC_PHI = ["Avery", "Quinn", "SC-100231", "1984-03-12"].freeze

  test "patient requests never write synthetic PHI to the log" do
    output = StringIO.new
    sink = ActiveSupport::Logger.new(output).tap { |l| l.level = :info }
    Rails.logger.broadcast_to(sink)

    patient = patients(:avery)
    headers = auth_headers_for(users(:dr_okafor))
    get api_v1_patient_path(patient), headers: headers
    get api_v1_patients_path, params: { q: "Quinn" }, headers: headers
    post api_v1_patient_messages_path(patient), params: { message: { body: "Avery Quinn, DOB 1984-03-12" } }, headers: headers

    SYNTHETIC_PHI.each { |value| refute_includes output.string, value }
  ensure
    Rails.logger.stop_broadcasting_to(sink)
  end
end
