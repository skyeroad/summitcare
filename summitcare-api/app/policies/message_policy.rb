class MessagePolicy < ApplicationPolicy
  CLINICAL_ROLES = %w[patient clinician].freeze

  def show? = Scope.new(user, Message).resolve.exists?(record.id)
  def create? = CLINICAL_ROLES.include?(user.role) &&
                PatientPolicy::Scope.new(user, Patient).resolve.exists?(record.patient_id)

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless CLINICAL_ROLES.include?(user.role)
      scope.where(patient_id: PatientPolicy::Scope.new(user, Patient).resolve.select(:id))
    end
  end
end
