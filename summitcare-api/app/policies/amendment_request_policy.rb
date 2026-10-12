class AmendmentRequestPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.none unless %w[patient clinician].include?(user.role)
      scope.where(patient_id: PatientPolicy::Scope.new(user, Patient).resolve.select(:id))
    end
  end
end
