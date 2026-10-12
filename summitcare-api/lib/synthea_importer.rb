# Loads Synthea FHIR bundles as synthetic patients and lab results (Solution 32).
class SyntheaImporter
  def initialize(directory, clinician:)
    @directory = directory
    @clinician = clinician
  end

  def import!(limit: 50)
    bundles.first(limit).each_with_index do |bundle, index|
      resources = bundle.fetch("entry").map { |entry| entry.fetch("resource") }
      fhir_patient = resources.find { |r| r["resourceType"] == "Patient" }
      patient = Patient.create!(patient_attributes(fhir_patient, index))
      resources.select { |r| r["resourceType"] == "Observation" && r["valueQuantity"] }
               .first(20)
               .each { |observation| import_lab_result(patient, observation) }
    end
  end

  private

  def bundles
    Dir[File.join(@directory, "*.json")].sort.lazy
      .map { |path| JSON.parse(File.read(path)) }
      .select { |b| b["entry"]&.any? { |e| e.dig("resource", "resourceType") == "Patient" } }
  end

  def patient_attributes(fhir, index)
    name = fhir.fetch("name").first
    address = fhir.fetch("address", []).first || {}
    {
      mrn: format("SC-9%05d", index),
      first_name: name.fetch("given").first,
      last_name: name.fetch("family"),
      date_of_birth: Date.iso8601(fhir.fetch("birthDate")),
      phone: fhir.fetch("telecom", []).find { |t| t["system"] == "phone" }&.fetch("value", nil),
      email: "synthetic+#{index}@patients.summitcare.example",
      address_line1: address.fetch("line", []).first,
      city: address["city"], state: address["state"], postal_code: address["postalCode"]
    }
  end

  def import_lab_result(patient, observation)
    coding = observation.dig("code", "coding", 0) || {}
    patient.lab_results.create!(
      ordered_by: @clinician, test_code: coding["code"], test_name: coding["display"],
      value: observation.dig("valueQuantity", "value").to_s,
      unit: observation.dig("valueQuantity", "unit"),
      resulted_at: observation["effectiveDateTime"]
    )
  end
end
