class Offboarding
  FOLLOW_UPS = {
    "admin" => ["Rotate shared break-glass and vendor console credentials"],
    "compliance_officer" => ["Reassign open incidents and record requests"]
  }.freeze

  def self.call(user:, performed_by:, reason:)
    now = Time.current
    User.transaction do
      user.update!(deactivated_at: now)
      user.sessions.destroy_all
      user.device_sessions.where(revoked_at: nil).update_all(revoked_at: now, revoked_reason: "offboarded")
      user.webauthn_credentials.destroy_all
      CareTeamMembership.where(user:).where("ends_on IS NULL OR ends_on > ?", now.to_date)
                        .update_all(ends_on: now.to_date)
      BreakGlassGrant.where(user:).where("expires_at > ?", now).update_all(expires_at: now)
      AuditLog.record!(action: "update", subject: user, reason:,
                       metadata: { event: "offboarded", performed_by_id: performed_by.id })
    end
    FOLLOW_UPS.fetch(user.role, [])
  end
end
