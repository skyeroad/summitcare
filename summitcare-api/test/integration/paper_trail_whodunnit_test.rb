require "test_helper"

# Not in the book: Solution 16 over HTTP. With the book's
# `def user_for_paper_trail = Current.user&.id`, ApplicationController's
# before_action runs before Api::V1::BaseController authenticates, and the
# first test fails with whodunnit nil (see BOOK-CORRECTIONS.md).
class PaperTrailWhodunnitTest < ActionDispatch::IntegrationTest
  setup do
    @result = lab_results(:avery_a1c)
    @headers = auth_headers_for(users(:dr_okafor))
  end

  test "an API edit records the signed-in user as whodunnit" do
    patch api_v1_patient_lab_result_path(@result.patient, @result), headers: @headers, as: :json,
          params: { lab_result: { notes: "Recheck fasting", lock_version: @result.lock_version } }
    assert_response :success
    assert_equal users(:dr_okafor).id.to_s, @result.versions.last.whodunnit
  end

  test "a stale edit is a 409, not a silent overwrite" do
    stale = @result.lock_version
    @result.update!(notes: "Edited elsewhere")
    patch api_v1_patient_lab_result_path(@result.patient, @result), headers: @headers, as: :json,
          params: { lab_result: { notes: "My edit", lock_version: stale } }
    assert_response :conflict
    assert_equal "Edited elsewhere", @result.reload.notes
  end

  test "patients cannot edit lab results" do
    patch api_v1_patient_lab_result_path(@result.patient, @result), headers: auth_headers_for(users(:avery)),
          as: :json, params: { lab_result: { notes: "x", lock_version: @result.lock_version } }
    assert_response :not_found
  end
end
