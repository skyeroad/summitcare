class Api::V1::RecordExportsController < Api::V1::BaseController
  before_action :set_patient
  rate_limit to: 5, within: 1.hour, only: :create
  audit_phi_access :create, :show

  def create
    authorize @patient, :export_records?
    record_request = @patient.record_requests.create!(
      format: params.fetch(:export_format, "both"))
    audit!("create", record_request)
    RecordExportJob.perform_later(record_request)
    render json: { id: record_request.id, due_on: record_request.due_on }, status: :accepted
  end

  def show
    authorize @patient, :export_records?
    record_request = @patient.record_requests.fulfilled
      .where(fulfilled_at: 7.days.ago..).order(:fulfilled_at).last
    return head :not_found unless record_request

    file = params[:file] == "pdf" ? record_request.pdf : record_request.fhir_bundle
    audit!("download", record_request, patient: @patient, metadata: { file: params[:file] })
    render json: { url: file.url(expires_in: 5.minutes, disposition: :attachment) }
  end

  private

  def set_patient
    @patient = policy_scope(Patient).find(params[:patient_id])
  end
end
