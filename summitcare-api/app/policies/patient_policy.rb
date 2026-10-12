class PatientPolicy < ApplicationPolicy
  def show? = Scope.new(user, Patient).resolve.exists?(record.id)
  def export_records? = user.patient? && record.user_id == user.id                  # Solution 18
  def request_amendment? = user.patient? && record.user_id == user.id              # Solution 20

  class Scope < ApplicationPolicy::Scope
    def resolve
      case user.role
      when "patient" then scope.where(user_id: user.id)
      when "clinician" then care_team_patients
      when "front_desk", "billing" then scope.all
      else scope.none
      end
    end

    private

    def care_team_patients
      allowed = scope.where(id: CareTeamMembership.current.where(user_id: user.id).select(:patient_id))
      grant = Current.break_glass_grant
      grant ? allowed.or(scope.where(id: grant.patient_id)) : allowed
    end
  end
end
