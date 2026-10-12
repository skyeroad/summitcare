# Parent of the staff console controllers (Solution 1). Cookie sessions, not
# bearer tokens, and nothing but MFA enrollment until a staff member enrolls.
class Console::BaseController < ApplicationController
  include ActionController::Cookies
  include ActionController::Flash # redirect_to ..., alert: (SessionsController)
  include Authentication

  before_action :require_mfa_enrollment

  private

  def require_mfa_enrollment
    user = Current.user
    return unless user&.mfa_required? && !user.mfa_enrolled?
    redirect_to new_console_mfa_enrollment_path
  end
end
