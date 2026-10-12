# Bearer-token authentication for the mobile API (Solutions 3, 5, and 30).
module ApiAuthentication
  extend ActiveSupport::Concern
  include ActionController::HttpAuthentication::Token::ControllerMethods

  included { before_action :authenticate_device_session! }

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :authenticate_device_session!, **options
    end
  end

  private

  def authenticate_device_session!
    device_session = authenticate_with_http_token do |token, _|
      DeviceSession.find_by(access_token_digest: DeviceSession.digest(token)) # revoked rows too
    end
    return reject_token("device_revoked") if device_session&.revoked_at
    return reject_token("invalid_token") unless device_session&.access_expires_at&.future? &&
                                                 device_session.user.active?
    if (reason = device_session.timeout_reason) # Solution 5
      device_session.revoke!(reason)
      return reject_token("device_revoked")
    end

    device_session.record_activity!
    Current.device_session = device_session
    Current.user = device_session.user
  end

  def reject_token(error) = render(json: { error: }, status: :unauthorized)
end
