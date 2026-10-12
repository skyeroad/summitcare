class Api::V1::DeviceSessionsController < Api::V1::BaseController
  # index lists active devices (device_name, last_seen_at) for the Devices screen
  def index
    sessions = policy_scope(DeviceSession).live.order(last_seen_at: :desc)
    render json: sessions.map { |s|
      { id: s.id, device_name: s.device_name, last_seen_at: s.last_seen_at, current: s.id == Current.device_session.id }
    }
  end

  def destroy
    device_session = policy_scope(DeviceSession).find(params[:id])
    authorize device_session
    device_session.revoke!("reported_lost")
    AuditLog.record!(action: "update", subject: device_session,
                     metadata: { event: "device_revoked", device_name: device_session.device_name })
    head :no_content
  end
end
