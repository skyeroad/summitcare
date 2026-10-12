require "test_helper"

class UserMfaTest < ActiveSupport::TestCase
  test "a TOTP code cannot be replayed" do
    user = users(:dr_okafor)
    user.update!(otp_secret: ROTP::Base32.random, otp_enabled_at: Time.current)
    code = ROTP::TOTP.new(user.otp_secret).now

    assert user.verify_otp(code)
    assert_not user.verify_otp(code)
  end
end
