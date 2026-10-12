module User::Mfa
  def start_otp_enrollment!
    update!(otp_secret: ROTP::Base32.random, otp_enabled_at: nil)
    uri = totp.provisioning_uri(email_address)
    RQRCode::QRCode.new(uri).as_svg(module_size: 4)
  end

  def confirm_otp_enrollment!(code)
    return false unless verify_otp(code)
    update!(otp_enabled_at: Time.current)
    RecoveryCode.generate_for!(self) # shown once, never stored in plain text
  end

  def verify_second_factor(code)
    return true if otp_enabled_at.nil? # not enrolled yet: Console::BaseController forces enrollment
    verify_otp(code) || RecoveryCode.redeem(self, code)
  end

  def verify_otp(code)
    return false if otp_secret.blank? || code.blank?
    with_lock do
      at = totp.verify(code.to_s.delete(" "), drift_behind: 30, drift_ahead: 30, after: otp_last_used_at)
      at.present? && update!(otp_last_used_at: Time.at(at))
    end
  end

  private def totp = ROTP::TOTP.new(otp_secret, issuer: "SummitCare")
end
