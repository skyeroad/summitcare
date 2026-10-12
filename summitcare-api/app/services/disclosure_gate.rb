class DisclosureGate
  class NotAuthorized < StandardError; end

  def self.authorize!(patient:, recipient:, purpose:)
    patient.patient_authorizations.active.find_by(recipient:, purpose:) or
      raise NotAuthorized, "No active authorization for #{purpose} to #{recipient}"
  end
end
