require "test_helper"

class LabResultIntegrityTest < ActiveSupport::TestCase
  test "versions record the change and keep PHI encrypted at rest" do
    result = lab_results(:avery_a1c)
    PaperTrail.request(whodunnit: users(:dr_okafor).id.to_s) { result.update!(value: "6.1") }

    version = result.versions.last
    assert_equal users(:dr_okafor).id.to_s, version.whodunnit
    assert version.encrypted_attribute?(:object_changes)
    refute_includes version.ciphertext_for(:object_changes), "6.1"
  end

  test "a stale copy cannot overwrite a newer edit" do
    first = LabResult.find(lab_results(:avery_a1c).id)
    second = LabResult.find(first.id)
    first.update!(notes: "Repeat in 3 months")
    assert_raises(ActiveRecord::StaleObjectError) { second.update!(notes: "No follow-up") }
  end
end
