# Electronic lab reporting to the (fictional) state health department
# (Solution 19). Goes through HttpClient, so the vendor registry guards it.
class StatePublicHealthClient
  RECIPIENT_ADDRESS = "Epidemiology Division, 100 Capitol Way, Statehouse City, ST 00000"
  BASE_URL = "https://elr.health.state.example/"

  def initialize(connection: HttpClient.for(:state_public_health, phi: true, url: BASE_URL))
    @connection = connection
  end

  def submit_lab_report(lab_result)
    patient = lab_result.patient
    @connection.post("lab-reports", {
      patient: { mrn: patient.mrn, first_name: patient.first_name, last_name: patient.last_name,
                 date_of_birth: patient.date_of_birth&.iso8601, postal_code: patient.postal_code },
      result: { loinc: lab_result.test_code, value: lab_result.value, unit: lab_result.unit,
                resulted_at: lab_result.resulted_at.iso8601 }
    }).body
  end
end
