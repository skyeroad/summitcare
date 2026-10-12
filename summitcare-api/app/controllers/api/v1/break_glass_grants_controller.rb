class Api::V1::BreakGlassGrantsController < Api::V1::BaseController
  rate_limit to: 5, within: 1.hour, only: :create, by: -> { Current.user.id }

  def create
    authorize BreakGlassGrant
    patient = Patient.find_by!(mrn: params.require(:mrn))
    grant = BreakGlassGrant.open!(user: Current.user, patient:, reason: params.require(:reason))
    Current.break_glass_grant = grant
    AuditLog.record!(action: "break_glass", subject: grant, patient:, reason: grant.reason)
    BreakGlassMailer.with(grant:).opened.deliver_later
    render json: { id: grant.id, patient_id: patient.id, expires_at: grant.expires_at }, status: :created
  end
end
