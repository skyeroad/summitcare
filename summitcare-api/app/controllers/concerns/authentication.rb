# Cookie sessions for the staff console. The Rails 8 authentication generator's
# concern, with idle and absolute timeouts (Solution 5) and no helper_method
# (API controllers have no view helpers).
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    resume_session
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    return Current.session if Current.session
    cookie_session = find_session_by_cookie or return

    if (reason = cookie_session.timeout_reason)
      end_timed_out_session(cookie_session, reason)
    else
      cookie_session.record_activity!
      Current.session = cookie_session
    end
  end

  def end_timed_out_session(cookie_session, reason)
    Current.user = cookie_session.user # so the audit event names the actor
    AuditLog.record!(action: "sign_out", subject: cookie_session.user, reason:)
    cookie_session.destroy
    cookies.delete(:session_id)
    nil
  end

  def find_session_by_cookie
    Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to new_session_path
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || console_root_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed[:session_id] = { value: session.id, httponly: true, same_site: :strict,
                                      secure: Rails.env.production? }
    end
  end

  def terminate_session
    AuditLog.record!(action: "sign_out", subject: Current.user)
    Current.session.destroy
    cookies.delete(:session_id)
  end
end
