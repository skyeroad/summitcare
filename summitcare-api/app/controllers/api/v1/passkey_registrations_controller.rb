class Api::V1::PasskeyRegistrationsController < Api::V1::BaseController
  include PasskeyChallenges # store_challenge / take_challenge via Rails.cache, 5-minute expiry
  skip_after_action :verify_authorized

  def new
    options = WebAuthn::Credential.options_for_create(
      user: { id: Current.user.webauthn_id, name: Current.user.email_address },
      exclude: Current.user.webauthn_credentials.pluck(:external_id),
      authenticator_selection: { resident_key: "required", user_verification: "required" }
    )
    render json: { challenge_id: store_challenge(options.challenge), options: }
  end

  def create
    challenge = take_challenge(params[:challenge_id]) or return head(:unprocessable_entity)
    credential = WebAuthn::Credential.from_create(credential_params)
    credential.verify(challenge, user_verification: true)
    Current.user.webauthn_credentials.create!(external_id: credential.id,
      public_key: credential.public_key, sign_count: credential.sign_count,
      nickname: params[:nickname])
    head :created
  rescue WebAuthn::Error
    head :unprocessable_entity
  end

  private

  # The WebAuthn PublicKeyCredential JSON, key by key (Brakeman flags permit!).
  def credential_params
    params.require(:credential).permit(:type, :id, :rawId, :authenticatorAttachment,
      response: [:clientDataJSON, :attestationObject, :authenticatorData, :signature, :userHandle, { transports: [] }],
      clientExtensionResults: {}).to_h
  end
end
