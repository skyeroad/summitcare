class Api::V1::MessagesController < Api::V1::BaseController
  audit_phi_access :index, :create

  def index
    patient = policy_scope(Patient).find(params[:patient_id])
    messages = policy_scope(Message).where(patient:).order(:created_at).to_a
    audit!("list", Message, patient:, metadata: { record_ids: messages.map(&:id) })
    render json: messages.map { |m| MessageSerializer.new(m).as_json }
  end

  def create
    patient = policy_scope(Patient).find(params[:patient_id])
    message = authorize patient.messages.new(body: params.expect(message: [:body])[:body], sender: Current.user)
    message.save!
    audit!("create", message)
    render json: MessageSerializer.new(message).as_json, status: :created
  end
end
