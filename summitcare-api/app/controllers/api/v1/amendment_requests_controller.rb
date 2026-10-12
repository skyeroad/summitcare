class Api::V1::AmendmentRequestsController < Api::V1::BaseController
  AMENDABLE = { "LabResult" => :lab_results, "Appointment" => :appointments,
                "Document" => :documents }.freeze
  before_action :set_patient
  audit_phi_access :index, :create

  def index
    requests = policy_scope(AmendmentRequest).where(patient: @patient).order(:created_at).to_a
    audit!("list", AmendmentRequest, patient: @patient, metadata: { record_ids: requests.map(&:id) })
    render json: requests.map { |r|
      { id: r.id, target_type: r.target_type, target_id: r.target_id, status: r.status,
        due_on: r.effective_due_on, requested_change: r.requested_change }
    }
  end

  def create
    authorize @patient, :request_amendment?
    association = AMENDABLE.fetch(params.require(:target_type)) { raise ActionController::BadRequest }
    target = @patient.public_send(association).find(params.require(:target_id))
    amendment = @patient.amendment_requests.create!(
      target:, requested_change: params.require(:requested_change), reason: params[:reason])
    audit!("create", amendment, patient: @patient)
    render json: { id: amendment.id, status: amendment.status, due_on: amendment.due_on }, status: :created
  end

  private

  def set_patient
    @patient = policy_scope(Patient).find(params[:patient_id])
  end
end
