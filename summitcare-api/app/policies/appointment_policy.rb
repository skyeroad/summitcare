# Front desk and billing see appointments, but AppointmentSerializer drops the
# visit reason for them (Solution 4).
class AppointmentPolicy < ApplicationPolicy
  def show? = Scope.new(user, Appointment).resolve.exists?(record.id)
  def create? = %w[front_desk clinician].include?(user.role) &&
                PatientPolicy::Scope.new(user, Patient).resolve.exists?(record.patient_id)

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.where(patient_id: PatientPolicy::Scope.new(user, Patient).resolve.select(:id))
  end
end
