class SessionsController < Console::BaseController
  allow_unauthenticated_access only: %i[new create]
  skip_before_action :require_mfa_enrollment
  skip_after_action :verify_authorized # sign-in has no record to authorize (Solution 4)
  rate_limit to: 10, within: 3.minutes, only: :create, name: "by-ip"
  rate_limit to: 5, within: 15.minutes, only: :create, name: "by-account", # name: needs Rails 8.0+
             by: -> { params[:email_address].to_s.strip.downcase }

  # The console's sign-in form is out of scope for the companion code; this
  # describes the fields the form posts.
  def new
    render json: { fields: %w[email_address password otp_code] }
  end

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))
    if user&.active? && user.verify_second_factor(params[:otp_code])
      start_new_session_for user
      AuditLog.record!(action: "sign_in", subject: user)
      redirect_to after_authentication_url
    else
      AuditLog.record!(action: "sign_in_failed", subject: user) # user is nil for unknown emails
      redirect_to new_session_path, alert: "Those details didn't work."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
