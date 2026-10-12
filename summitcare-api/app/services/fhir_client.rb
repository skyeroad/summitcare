class FhirClient
  def initialize(base_url: "https://fhir.regional-hie.example/r4/")
    tls = Rails.application.credentials.hie_mtls
    @conn = HttpClient.for(:regional_hie, phi: true, url: base_url,
      headers: { "Accept" => "application/fhir+json" },
      ssl: { client_cert: OpenSSL::X509::Certificate.new(tls[:certificate]),
             client_key: OpenSSL::PKey.read(tls[:private_key]),
             min_version: OpenSSL::SSL::TLS1_2_VERSION })
  end

  def lab_observations(patient_reference)
    @conn.get("Observation", patient: patient_reference, category: "laboratory").body
  end
end
