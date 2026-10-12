class RecordExportJob < ApplicationJob
  def perform(record_request)
    patient = record_request.patient
    record_request.update!(status: "in_progress")
    bundle = FhirExport::BundleBuilder.new(patient).build
    record_request.fhir_bundle.attach(io: StringIO.new(JSON.generate(bundle)),
      filename: "summitcare-records-#{record_request.id}.json", content_type: "application/fhir+json")
    record_request.pdf.attach(io: StringIO.new(RecordExportPdf.new(patient).render),
      filename: "summitcare-records-#{record_request.id}.pdf", content_type: "application/pdf")
    record_request.update!(status: "fulfilled", fulfilled_at: Time.current)

    Current.set(user: patient.user) do
      AuditLog.record!(action: "export", subject: record_request, patient:,
                       reason: "right_of_access", metadata: { format: record_request.format })
    end
    PatientNotifier.deliver(patient, :records_ready) # Solution 21
  end
end
