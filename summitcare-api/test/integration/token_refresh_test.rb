require "test_helper"

class TokenRefreshTest < ActionDispatch::IntegrationTest
  test "reusing a rotated refresh token revokes the session" do
    session, first = DeviceSession.start!(user: users(:avery), device_id: "dev-1", device_name: "Test iPhone")

    post api_v1_token_refresh_path, params: { refresh_token: first[:refresh_token], device_id: "dev-1" }, as: :json
    assert_response :success
    second = response.parsed_body

    post api_v1_token_refresh_path, params: { refresh_token: first[:refresh_token], device_id: "dev-1" }, as: :json
    assert_response :unauthorized
    assert_equal "refresh_token_reuse", session.reload.revoked_reason

    get api_v1_patients_path, headers: { "Authorization" => "Bearer #{second['access_token']}" }
    assert_response :unauthorized
  end
end
