require "test_helper"

class Deidentify::SafeHarborTest < ActiveSupport::TestCase
  ALLOWED = %w[subject_key birth_year age_90_plus state zip3 result_year
               loinc_code value_numeric unit].freeze

  test "rows contain only allowlisted fields and generalize ZIP and age" do
    safe_harbor = Deidentify::SafeHarbor.new(pseudonymizer: Deidentify::Pseudonymizer.new,
                                             today: Date.new(2026, 10, 12))
    lab = lab_results(:avery_a1c)
    lab.patient.update!(postal_code: "83001", date_of_birth: Date.new(1930, 5, 1))
    row = safe_harbor.lab_observation(lab)

    assert_equal ALLOWED.sort, row.keys.map(&:to_s).sort
    assert_equal "000", row[:zip3]
    assert_nil row[:birth_year]
    assert row[:age_90_plus]
  end

  test "the export job writes de-identified rows to the analytics database" do
    DeidentifiedExportJob.perform_now
    assert_equal LabResult.count, Analytics::LabObservation.count
    assert_equal 1, Analytics::LabObservation.where(subject_key: PatientSurrogate.find_by!(patient: patients(:avery)).surrogate_id).count
  end
end
