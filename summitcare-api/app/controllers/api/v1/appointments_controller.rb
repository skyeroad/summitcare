class Api::V1::AppointmentsController < Api::V1::BaseController
  before_action :set_patient
  audit_phi_access :index, :show, :create

  def index
    appointments = policy_scope(Appointment).where(patient: @patient).order(:starts_at).to_a
    audit!("list", Appointment, patient: @patient, metadata: { record_ids: appointments.map(&:id) })
    render json: appointments.map { |a| AppointmentSerializer.new(a, viewer: Current.user).as_json }
  end

  def show
    appointment = authorize policy_scope(Appointment).where(patient: @patient).find(params[:id])
    audit!("view", appointment)
    render json: AppointmentSerializer.new(appointment, viewer: Current.user).as_json
  end

  def create
    attrs = params.expect(appointment: %i[clinician_id starts_at ends_at reason])
    appointment = authorize @patient.appointments.new(attrs)
    appointment.save!
    audit!("create", appointment)
    render json: AppointmentSerializer.new(appointment, viewer: Current.user).as_json, status: :created
  end

  private

  def set_patient
    @patient = policy_scope(Patient).find(params[:patient_id])
  end
end
