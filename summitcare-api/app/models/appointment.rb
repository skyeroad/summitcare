class Appointment < ApplicationRecord
  include ProtectedHealthInformation
  include Amendable

  STATUSES = %w[scheduled checked_in completed cancelled no_show].freeze

  belongs_to :patient
  belongs_to :clinician, class_name: "User"
  phi_attributes :reason

  validates :starts_at, :ends_at, presence: true
  validates :status, inclusion: { in: STATUSES }
end
