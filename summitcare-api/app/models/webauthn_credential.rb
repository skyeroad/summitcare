class WebauthnCredential < ApplicationRecord
  belongs_to :user

  def self.authenticate(response_params, challenge:)
    assertion = WebAuthn::Credential.from_get(response_params)
    stored = find_by!(external_id: assertion.id)
    assertion.verify(challenge, public_key: stored.public_key,
                     sign_count: stored.sign_count, user_verification: true)
    stored.update!(sign_count: assertion.sign_count)
    stored.user if stored.user.active?
  rescue WebAuthn::Error, ActiveRecord::RecordNotFound
    nil
  end
end
