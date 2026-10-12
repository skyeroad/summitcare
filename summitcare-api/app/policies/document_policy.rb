class DocumentPolicy < ApplicationPolicy
  def show? = Scope.new(user, Document).resolve.exists?(record.id)
  def create? = PatientPolicy::Scope.new(user, Patient).resolve.exists?(record.patient_id) &&
                %w[patient clinician front_desk].include?(user.role)

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when "patient", "clinician", "front_desk"
        scope.where(patient_id: PatientPolicy::Scope.new(user, Patient).resolve.select(:id))
      else scope.none
      end
    end
  end
end
