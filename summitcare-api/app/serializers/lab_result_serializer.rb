class LabResultSerializer
  FIELDS = {
    "patient" => %i[id patient_id test_code test_name value unit reference_range resulted_at],
    "clinician" => %i[id patient_id test_code test_name value unit reference_range resulted_at notes lock_version]
  }.freeze

  def initialize(lab_result, viewer:)
    @lab_result, @viewer = lab_result, viewer
  end

  def as_json(*)
    FIELDS.fetch(@viewer.role, []).index_with { |field| @lab_result.public_send(field) }
  end
end
