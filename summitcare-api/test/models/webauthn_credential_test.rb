require "test_helper"
require "webauthn/fake_client" # not loaded by require "webauthn"

class WebauthnCredentialTest < ActiveSupport::TestCase
  test "assertions without user verification are rejected" do
    client = WebAuthn::FakeClient.new("https://summitcare.example")
    reg_challenge = WebAuthn::Credential.options_for_create(
      user: { id: WebAuthn.generate_user_id, name: "avery.quinn@example.com" }).challenge
    created = WebAuthn::Credential.from_create(client.create(challenge: reg_challenge, user_verified: true))
    created.verify(reg_challenge)

    challenge = WebAuthn::Credential.options_for_get.challenge
    assertion = WebAuthn::Credential.from_get(client.get(challenge:, user_verified: false))
    assert_raises(WebAuthn::Error) do
      assertion.verify(challenge, public_key: created.public_key, sign_count: 0, user_verification: true)
    end
  end
end
