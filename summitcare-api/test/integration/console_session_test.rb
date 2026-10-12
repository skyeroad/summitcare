require "test_helper"

# Not in the book: the staff console's cookie session (Solutions 1 and 5).
class ConsoleSessionTest < ActionDispatch::IntegrationTest
  def sign_in(user, otp_code: nil)
    post session_path, params: { email_address: user.email_address, password: SYNTHETIC_PASSWORD, otp_code: }
  end

  test "staff without MFA can sign in but are sent to enrollment" do
    sign_in users(:morgan_reyes)
    assert_redirected_to console_root_url
    get console_root_path
    assert_redirected_to new_console_mfa_enrollment_path
  end

  test "enrolled staff need a TOTP code, and an idle session ends" do
    reyes = users(:morgan_reyes)
    reyes.update!(otp_secret: ROTP::Base32.random, otp_enabled_at: 1.day.ago)

    sign_in reyes, otp_code: "000000"
    assert_redirected_to new_session_path
    assert AuditEvent.exists?(action: "sign_in_failed", subject_id: reyes.id)

    sign_in reyes, otp_code: ROTP::TOTP.new(reyes.otp_secret).now
    get console_root_path
    assert_response :success

    travel 16.minutes
    get console_root_path
    assert_redirected_to new_session_path
    assert AuditEvent.exists?(action: "sign_out", reason: "idle_timeout", actor_id: reyes.id)
  end
end
