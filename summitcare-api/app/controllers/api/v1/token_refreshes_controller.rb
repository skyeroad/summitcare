class Api::V1::TokenRefreshesController < Api::V1::BaseController
  allow_unauthenticated_access
  skip_after_action :verify_authorized
  rate_limit to: 30, within: 1.minute

  def create
    tokens = DeviceSession.refresh(params.require(:refresh_token),
                                   device_id: params.require(:device_id))
    return render(json: tokens) if tokens

    # Solution 30: tell the app its device was revoked, even if its access token expired.
    session = DeviceSession.find_by_refresh_token(params[:refresh_token])
    session&.revoked_at ? render(json: { error: "device_revoked" }, status: :unauthorized) : head(:unauthorized)
  end
end
