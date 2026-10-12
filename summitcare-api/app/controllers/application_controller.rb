class ApplicationController < ActionController::API
  include Pundit::Authorization

  # Solution 4. `if:`/`unless:` rather than `only:`/`except:`, because Rails 7.1+
  # raises in development and test when a controller has no `index` action and the
  # callback names it (config.action_controller.raise_on_missing_callback_actions).
  after_action :verify_authorized, unless: -> { action_name == "index" }
  after_action :verify_policy_scoped, if: -> { action_name == "index" }

  before_action :set_current_request_details
  before_action :set_paper_trail_whodunnit # Solution 16

  rescue_from Pundit::NotAuthorizedError do
    head :not_found # don't confirm that the record exists
  end

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end

  rescue_from ActiveRecord::StaleObjectError do # Solution 16
    render json: { error: "conflict", message: "This record changed. Reload and try again." },
           status: :conflict
  end

  private

  def pundit_user = Current.user

  # A proc, so PaperTrail reads Current.user when the version is written, after
  # the authentication before_action in Api::V1::BaseController has run.
  def user_for_paper_trail = -> { Current.user&.id }

  # Read by AuditLog.record! (Solution 13).
  def set_current_request_details
    Current.request_id = request.request_id
    Current.ip_address = request.remote_ip
    Current.user_agent = request.user_agent
  end
end
