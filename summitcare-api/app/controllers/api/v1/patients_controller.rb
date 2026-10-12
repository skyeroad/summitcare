class Api::V1::PatientsController < Api::V1::BaseController
  audit_phi_access :index, :show

  def index
    patients = policy_scope(Patient).order(:id).to_a
    # Names are encrypted, so search runs in Ruby over the caller's own scope.
    # `q` is filtered from logs (Solution 15).
    if params[:q].present?
      needle = params[:q].to_s.downcase
      patients.select! { |p| [p.first_name, p.last_name, p.mrn].compact.any? { _1.downcase.include?(needle) } }
    end
    audit!("list", Patient, metadata: { record_ids: patients.map(&:id) })
    render json: patients.map { |patient| PatientSerializer.new(patient, viewer: Current.user).as_json }
  end

  def show
    patient = authorize Patient.find(params[:id])
    audit!("view", patient)
    render json: PatientSerializer.new(patient, viewer: Current.user).as_json
  end
end
