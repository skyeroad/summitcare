# Passkey sign-in (Solution 1): a discoverable credential, so no email is typed.
class Api::V1::PasskeySessionsController < Api::V1::BaseController
  include PasskeyChallenges
  allow_unauthenticated_access
  skip_after_action :verify_authorized
  rate_limit to: 10, within: 3.minutes, only: :create

  def new
    options = WebAuthn::Credential.options_for_get(user_verification: "required")
    render json: { challenge_id: store_challenge(options.challenge), options: }
  end

  def create
    challenge = take_challenge(params[:challenge_id]) or return head(:unprocessable_entity)
    user = WebauthnCredential.authenticate(credential_params, challenge:)
    unless user
      AuditLog.record!(action: "sign_in_failed", subject: nil, metadata: { method: "passkey" })
      return head(:unauthorized)
    end

    Current.user = user
    device_session, tokens = DeviceSession.start!(user:, device_id: params.require(:device_id),
                                                  device_name: params[:device_name])
    Current.device_session = device_session
    AuditLog.record!(action: "sign_in", subject: user, metadata: { method: "passkey" })
    render json: tokens, status: :created
  end

  private

  # The WebAuthn PublicKeyCredential JSON, key by key (Brakeman flags permit!).
  def credential_params
    params.require(:credential).permit(:type, :id, :rawId, :authenticatorAttachment,
      response: [:clientDataJSON, :attestationObject, :authenticatorData, :signature, :userHandle, { transports: [] }],
      clientExtensionResults: {}).to_h
  end
end
