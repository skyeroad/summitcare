require "test_helper"

# Corrected from the book (see BOOK-CORRECTIONS.md): the access token lives 15
# minutes, the same as the idle timeout, so after 16 idle minutes an API request
# can't even find the session. The refresh is what the app sends next.
class SessionTimeoutTest < ActionDispatch::IntegrationTest
  test "an idle device session is revoked" do
    session, tokens = DeviceSession.start!(user: users(:dr_okafor), device_id: "dev-1", device_name: "Test iPhone")
    travel 16.minutes
    post api_v1_token_refresh_path, params: { refresh_token: tokens[:refresh_token], device_id: "dev-1" }, as: :json
    assert_response :unauthorized
    assert_equal "idle_timeout", session.reload.revoked_reason
  end
end
