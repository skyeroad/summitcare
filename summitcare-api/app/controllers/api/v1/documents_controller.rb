class Api::V1::DocumentsController < Api::V1::BaseController
  audit_phi_access :index, :show, :create # AuditsPhiAccess (Solution 13)

  def index
    patient = policy_scope(Patient).find(params[:patient_id])
    documents = policy_scope(Document).where(patient:).order(:created_at).to_a
    audit!("list", Document, patient:, metadata: { record_ids: documents.map(&:id) })
    render json: documents.map { |d| { id: d.id, kind: d.kind, title: d.title, checksum: d.checksum, created_at: d.created_at } }
  end

  def show
    document = policy_scope(Document).where(patient_id: params[:patient_id]).find(params[:id])
    authorize document
    audit!("download", document) # AuditLog.record! plus the audited-action check

    ttl = Rails.configuration.active_storage.service_urls_expire_in
    url = document.file.url(expires_in: ttl, disposition: :attachment,
                            filename: "document-#{document.id}#{document.file.filename.extension_with_delimiter}")
    render json: { url:, expires_at: ttl.from_now.iso8601, content_type: document.file.content_type }
  end

  def create
    patient = policy_scope(Patient).find(params[:patient_id])
    upload = params.expect(document: [:kind, :title, :file])
    file = upload[:file]
    document = patient.documents.new(kind: upload[:kind], title: upload[:title],
                                     uploaded_by: Current.user)
    authorize document
    document.checksum = Digest::SHA256.file(file.path).hexdigest
    document.file.attach(io: file, filename: "document#{File.extname(file.original_filename)}",
                         content_type: file.content_type)
    document.save!
    audit!("create", document)
    render json: { id: document.id, checksum: document.checksum }, status: :created
  end
end
