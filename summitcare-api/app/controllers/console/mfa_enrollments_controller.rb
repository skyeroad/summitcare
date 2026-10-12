# TOTP enrollment for workforce users (Solution 1).
class Console::MfaEnrollmentsController < Console::BaseController
  skip_before_action :require_mfa_enrollment

  def new
    authorize Current.user, :manage_own_mfa?
    render json: { qr_svg: Current.user.start_otp_enrollment! }
  end

  def create
    authorize Current.user, :manage_own_mfa?
    codes = Current.user.confirm_otp_enrollment!(params.require(:otp_code))
    return head(:unprocessable_entity) unless codes
    render json: { recovery_codes: codes } # shown once
  end
end
