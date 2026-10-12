# One allowlisted JSON line per request (Solution 15). Applies in every
# environment, so the PHI log-leak test exercises the production format.
class AllowlistedJsonFormatter
  FIELDS = %i[method path format controller action status duration db view
              request_id user_id device_session_id exception_class].freeze

  def call(data) = JSON.generate(data.slice(*FIELDS))
end

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = AllowlistedJsonFormatter.new
  config.lograge.custom_payload do |controller|
    { request_id: controller.request.request_id, user_id: Current.user&.id,
      device_session_id: Current.device_session&.id }
  end
  config.lograge.custom_options = ->(event) { { exception_class: event.payload[:exception]&.first } }
end
