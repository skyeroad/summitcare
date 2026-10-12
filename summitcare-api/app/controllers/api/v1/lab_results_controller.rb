class Api::V1::LabResultsController < Api::V1::BaseController
  audit_phi_access :index, :show, :update

  def index
    patient = policy_scope(Patient).find(params[:patient_id])
    results = policy_scope(LabResult).where(patient:).order(resulted_at: :desc).to_a
    audit!("list", LabResult, patient:, metadata: { record_ids: results.map(&:id) })
    render json: results.map { |r| LabResultSerializer.new(r, viewer: Current.user).as_json }
  end

  def show
    result = authorize LabResult.find(params[:id])
    audit!("view", result)
    render json: LabResultSerializer.new(result, viewer: Current.user).as_json
  end

  # Clinicians edit notes. lock_version makes a stale edit a 409 (Solution 16);
  # PaperTrail records who changed what.
  def update
    result = authorize LabResult.find(params[:id])
    result.update!(params.expect(lab_result: [:notes, :lock_version]))
    audit!("update", result)
    render json: LabResultSerializer.new(result, viewer: Current.user).as_json
  end
end
