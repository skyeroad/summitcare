# Minimum necessary by role (Solution 4): billing and front desk get contact and
# demographic fields, not more.
class PatientSerializer
  FIELDS = {
    "patient" => %i[id mrn first_name last_name date_of_birth phone email address_line1 city state postal_code],
    "clinician" => %i[id mrn first_name last_name date_of_birth phone email],
    "front_desk" => %i[id mrn first_name last_name date_of_birth phone email],
    "billing" => %i[id mrn first_name last_name date_of_birth address_line1 city state postal_code]
  }.freeze

  def initialize(patient, viewer:)
    @patient, @viewer = patient, viewer
  end

  def as_json(*)
    FIELDS.fetch(@viewer.role, []).index_with { |field| @patient.public_send(field) }
  end
end
