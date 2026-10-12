require "test_helper"

# Not in the book: Solution 30's device_revoked signal on both paths.
class DeviceRevocationTest < ActionDispatch::IntegrationTest
  test "a revoked device is told why, on API calls and on refresh" do
    session, tokens = DeviceSession.start!(user: users(:avery), device_id: "lost-phone", device_name: "Lost iPhone")
    other = auth_headers_for(users(:avery))

    delete api_v1_device_session_path(session), headers: other
    assert_response :no_content
    assert_equal "reported_lost", session.reload.revoked_reason

    get api_v1_patients_path, headers: { "Authorization" => "Bearer #{tokens[:access_token]}" }
    assert_response :unauthorized
    assert_equal "device_revoked", response.parsed_body["error"]

    post api_v1_token_refresh_path, params: { refresh_token: tokens[:refresh_token], device_id: "lost-phone" }, as: :json
    assert_equal "device_revoked", response.parsed_body["error"]
  end

  test "patients cannot revoke someone else's device" do
    session, _ = DeviceSession.start!(user: users(:jordan), device_id: "j-1", device_name: "iPhone")
    delete api_v1_device_session_path(session), headers: auth_headers_for(users(:avery))
    assert_response :not_found
    assert_nil session.reload.revoked_at
  end
end
