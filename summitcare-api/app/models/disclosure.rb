class Disclosure < ApplicationRecord
  include ProtectedHealthInformation
  phi_attributes :description

  belongs_to :patient
  belongs_to :disclosed_by, class_name: "User", optional: true # nil for automated feeds

  # §164.528(a)(1) exclusions, as purpose codes
  NON_ACCOUNTABLE_PURPOSES = %w[
    treatment payment health_care_operations to_individual authorization
    facility_directory involved_in_care national_security correctional_custody
    limited_data_set incidental
  ].freeze

  validates :recipient_name, :purpose, :description, :disclosed_at, presence: true
  before_validation { self.accountable = !NON_ACCOUNTABLE_PURPOSES.include?(purpose) }
  scope :for_accounting, -> { where(accountable: true) }

  def self.record!(patient:, recipient_name:, purpose:, description:,
                   recipient_address: nil, subject: nil)
    transaction do
      disclosure = create!(patient:, recipient_name:, recipient_address:, purpose:,
                           description:, disclosed_at: Time.current, disclosed_by: Current.user)
      AuditLog.record!(action: "disclose", subject: subject || disclosure, patient:,
                       metadata: { disclosure_id: disclosure.id, purpose: })
      disclosure
    end
  end
end
