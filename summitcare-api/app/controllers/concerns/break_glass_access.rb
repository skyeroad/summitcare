module BreakGlassAccess
  extend ActiveSupport::Concern

  included { before_action :load_break_glass_grant }

  private

  def load_break_glass_grant
    patient_id = params[:patient_id] || (params[:id] if controller_name == "patients")
    return unless patient_id && Current.user&.clinician?

    Current.break_glass_grant = BreakGlassGrant.active.find_by(user: Current.user, patient_id:)
  end
end
