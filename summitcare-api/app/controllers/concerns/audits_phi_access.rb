module AuditsPhiAccess
  extend ActiveSupport::Concern

  included do
    class_attribute :audited_phi_actions, default: []
    after_action :ensure_phi_access_audited
  end

  class_methods do
    def audit_phi_access(*actions) = self.audited_phi_actions += actions.map(&:to_s)
  end

  private

  def audit!(action, subject, patient: nil, reason: nil, metadata: {})
    AuditLog.record!(action:, subject:, patient:, reason:, metadata:)
    @phi_access_audited = true
  end

  def ensure_phi_access_audited
    return unless audited_phi_actions.include?(action_name) && response.successful?
    return if @phi_access_audited
    message = "#{self.class.name}##{action_name} returned PHI without an audit event"
    raise message if Rails.env.local?
    Rails.logger.error(message)
  end
end
