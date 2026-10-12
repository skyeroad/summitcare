require "test_helper"

class PatientEncryptionTest < ActiveSupport::TestCase
  test "PHI is stored as ciphertext" do
    # SC-109999, not the book's SC-100231: that MRN belongs to the avery fixture,
    # and Solution 16 makes mrn unique (see BOOK-CORRECTIONS.md).
    patient = Patient.create!(mrn: "SC-109999", first_name: "Avery",
                              last_name: "Quinn", date_of_birth: "1984-03-12")
    sql = Patient.sanitize_sql_array(["SELECT last_name FROM patients WHERE id = ?", patient.id])
    raw = Patient.connection.select_value(sql)

    refute_includes raw, "Quinn"
    assert patient.encrypted_attribute?(:last_name)
    assert_equal "Quinn", patient.reload.last_name
    assert_equal Date.new(1984, 3, 12), patient.date_of_birth
  end

  test "deterministic and blind-indexed lookups work on ciphertext" do
    assert_equal patients(:avery), Patient.find_by(mrn: "SC-100231")
    assert_equal patients(:avery), Patient.find_by(email: "Avery.Quinn@patients.summitcare.example")
    assert_equal [patients(:avery)], Patient.where(phone: "(555) 0142").to_a # where, not find_by: find_by skips blind_index
  end
end
