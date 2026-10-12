require "test_helper"
require "webauthn/fake_client"

# Not in the book: Solution 1's passkey ceremonies through the API.
class PasskeyTest < ActionDispatch::IntegrationTest
  setup do
    # Challenges live in Rails.cache, which is a null store in test by default.
    @cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    @client = WebAuthn::FakeClient.new("https://summitcare.example")
  end

  teardown { Rails.cache = @cache }

  test "register a passkey, then sign in with it" do
    avery = users(:avery)
    avery.update!(webauthn_id: WebAuthn.generate_user_id)
    headers = auth_headers_for(avery)

    get new_api_v1_passkey_registration_path, headers: headers
    options = response.parsed_body
    credential = @client.create(challenge: options.dig("options", "challenge"), user_verified: true)
    post api_v1_passkey_registration_path, headers: headers, as: :json,
         params: { challenge_id: options["challenge_id"], credential:, nickname: "iPhone" }
    assert_response :created

    get new_api_v1_passkey_session_path
    options = response.parsed_body
    assertion = @client.get(challenge: options.dig("options", "challenge"), user_verified: true)
    post api_v1_passkey_session_path, as: :json,
         params: { challenge_id: options["challenge_id"], credential: assertion, device_id: "dev-9" }
    assert_response :created
    assert response.parsed_body["access_token"].present?
    assert AuditEvent.exists?(action: "sign_in", actor_id: avery.id)

    post api_v1_passkey_session_path, as: :json,
         params: { challenge_id: options["challenge_id"], credential: assertion, device_id: "dev-9" }
    assert_response :unprocessable_entity # single-use challenge
  end
end
