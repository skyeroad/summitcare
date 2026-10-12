module FhirExport
  class BundleBuilder
    def initialize(patient) = @patient = patient

    def build
      entries = [{ fullUrl: patient_ref, resource: patient_resource }]
      entries += @patient.lab_results.map { |lab| wrap(observation(lab)) }
      entries += @patient.appointments.map { |appt| wrap(appointment(appt)) }
      entries += @patient.documents.map { |doc| wrap(document_reference(doc)) }
      { resourceType: "Bundle", type: "collection", timestamp: Time.current.iso8601, entry: entries }
    end

    private

    def patient_ref = @patient_ref ||= "urn:uuid:#{SecureRandom.uuid}"
    def wrap(resource) = { fullUrl: "urn:uuid:#{SecureRandom.uuid}", resource: }

    def patient_resource
      {
        resourceType: "Patient",
        identifier: [{ system: "https://summitcare.example/mrn", value: @patient.mrn }],
        name: [{ family: @patient.last_name, given: [@patient.first_name].compact }],
        birthDate: @patient.date_of_birth&.iso8601,
        telecom: [
          ({ system: "phone", value: @patient.phone } if @patient.phone.present?),
          ({ system: "email", value: @patient.email } if @patient.email.present?)
        ].compact,
        address: [{ line: [@patient.address_line1].compact, city: @patient.city,
                    state: @patient.state, postalCode: @patient.postal_code }]
      }
    end

    def observation(lab)
      {
        resourceType: "Observation", status: "final",
        code: { coding: [{ system: "http://loinc.org", code: lab.test_code, display: lab.test_name }] },
        subject: { reference: patient_ref },
        issued: lab.resulted_at.iso8601,
        referenceRange: [{ text: lab.reference_range }],
        note: amendment_notes(lab),
        **value_for(lab)
      }.compact
    end

    def value_for(lab)
      numeric = Float(lab.value, exception: false)
      numeric ? { valueQuantity: { value: numeric, unit: lab.unit } } : { valueString: lab.value }
    end

    def appointment(appt)
      {
        resourceType: "Appointment", status: fhir_appointment_status(appt.status),
        start: appt.starts_at.iso8601, end: appt.ends_at.iso8601,
        description: appt.reason,
        participant: [{ actor: { reference: patient_ref }, status: "accepted" }],
        comment: amendment_notes(appt)&.map { _1[:text] }&.join("\n")
      }.compact
    end

    def document_reference(doc)
      attachment = { contentType: doc.file.content_type, title: doc.title }
      attachment[:data] = Base64.strict_encode64(doc.file.download) if doc.file.attached?
      {
        resourceType: "DocumentReference", status: "current",
        type: { text: doc.kind.humanize },
        subject: { reference: patient_ref },
        date: doc.created_at.iso8601,
        content: [{ attachment: }],
        description: amendment_notes(doc)&.map { _1[:text] }&.join("\n")
      }.compact
    end

    # Amendments and statements of disagreement travel with the record (Solution 20).
    def amendment_notes(record)
      notes = record.amendment_materials.map { |m| { text: "#{m.kind.humanize} (#{m.created_at.to_date}): #{m.body}" } }
      notes.presence
    end

    def fhir_appointment_status(status)
      { "scheduled" => "booked", "checked_in" => "checked-in", "completed" => "fulfilled",
        "cancelled" => "cancelled", "no_show" => "noshow" }.fetch(status, "booked")
    end
  end
end
