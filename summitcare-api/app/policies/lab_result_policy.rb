class LabResultPolicy < ApplicationPolicy
  CLINICAL_ROLES = %w[patient clinician].freeze

  def show? = Scope.new(user, LabResult).resolve.exists?(record.id)
  def update? = user.clinician? && show?

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless CLINICAL_ROLES.include?(user.role)
      scope.where(patient_id: PatientPolicy::Scope.new(user, Patient).resolve.select(:id))
    end
  end
end
