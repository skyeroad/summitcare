module AuditLog
  module_function

  def record!(action:, subject:, patient: nil, reason: nil, metadata: {})
    grant = Current.break_glass_grant
    AuditEvent.create!(
      occurred_at: Time.current.utc.floor(6),
      actor_id: Current.user&.id, actor_role: Current.user&.role,
      action: action.to_s,
      subject_type: subject.is_a?(Class) ? subject.name : subject&.class&.name,
      subject_id: subject.is_a?(Class) ? nil : subject&.id,
      patient_id: patient_id_for(subject, patient),
      ip_address: Current.ip_address, user_agent: Current.user_agent,
      request_id: Current.request_id, device_session_id: Current.device_session&.id,
      reason: reason,
      metadata: grant ? metadata.merge(break_glass_grant_id: grant.id) : metadata
    )
  end

  def patient_id_for(subject, patient)
    return patient.id if patient
    return nil if subject.nil? || subject.is_a?(Class)
    subject.is_a?(Patient) ? subject.id : subject.try(:patient_id)
  end
end
