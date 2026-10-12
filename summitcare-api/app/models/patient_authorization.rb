class PatientAuthorization < ApplicationRecord
  include ProtectedHealthInformation
  phi_attributes :information_scope

  belongs_to :patient
  has_one_attached :signed_form
  has_one_attached :revocation_document

  validates :recipient, :purpose, :information_scope, :signed_at, presence: true
  validate { errors.add(:expires_on, "or an expiration event is required") if expires_on.blank? && expiration_event.blank? }

  scope :active, -> { where(revoked_at: nil).where("expires_on IS NULL OR expires_on >= ?", Date.current) }

  def revoke!(written_revocation:, received_at: Time.current)
    revocation_document.attach(written_revocation)
    update!(revoked_at: received_at)
  end
end
