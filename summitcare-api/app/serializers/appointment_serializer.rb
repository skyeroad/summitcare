class AppointmentSerializer
  FIELDS = {
    "patient" => %i[id patient_id clinician_id starts_at ends_at status reason],
    "clinician" => %i[id patient_id clinician_id starts_at ends_at status reason],
    "front_desk" => %i[id patient_id clinician_id starts_at ends_at status],
    "billing" => %i[id patient_id clinician_id starts_at ends_at status]
  }.freeze

  def initialize(appointment, viewer:)
    @appointment, @viewer = appointment, viewer
  end

  def as_json(*)
    FIELDS.fetch(@viewer.role, []).index_with { |field| @appointment.public_send(field) }
  end
end
