class Message < ApplicationRecord
  include ProtectedHealthInformation
  phi_attributes :body

  belongs_to :patient
  belongs_to :sender, class_name: "User"

  validates :body, presence: true

  after_create_commit :notify_patient, unless: -> { sender_id == patient.user_id }

  private

  def notify_patient = PatientNotifier.deliver(patient, :new_message, message: self)
end
