# Password (plus TOTP, if enrolled) sign-in for the mobile app. Issues a
# DeviceSession (Solution 3). Passkeys use PasskeySessionsController.
class Api::V1::SessionsController < Api::V1::BaseController
  allow_unauthenticated_access only: :create
  skip_after_action :verify_authorized
  rate_limit to: 10, within: 3.minutes, only: :create, name: "by-ip"
  rate_limit to: 5, within: 15.minutes, only: :create, name: "by-account",
             by: -> { params[:email_address].to_s.strip.downcase }

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))
    if user&.active? && user.verify_second_factor(params[:otp_code])
      Current.user = user
      device_session, tokens = DeviceSession.start!(user:, device_id: params.require(:device_id),
                                                    device_name: params[:device_name])
      Current.device_session = device_session
      AuditLog.record!(action: "sign_in", subject: user)
      render json: tokens, status: :created
    else
      AuditLog.record!(action: "sign_in_failed", subject: user)
      head :unauthorized
    end
  end

  def destroy
    Current.device_session.revoke!("signed_out")
    AuditLog.record!(action: "sign_out", subject: Current.user)
    head :no_content
  end
end
