class IncidentScope
  READ_ACTIONS = %w[view list export download disclose].freeze

  def self.patient_ids(from:, to:, actor_id: nil, device_session_id: nil)
    events = AuditEvent.where(occurred_at: from..to, action: READ_ACTIONS)
    events = events.where(actor_id:) if actor_id
    events = events.where(device_session_id:) if device_session_id
    events.where.not(patient_id: nil).distinct.pluck(:patient_id)
  end
end
