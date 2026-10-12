# Error tracking with PHI scrubbed before send (Solution 15). Sentry is listed in
# config/vendors.yml with receives_phi: false; this initializer is what keeps it true.
PHI_PATTERNS = [/SC-\d{6}/, /[\w.+-]+@[\w-]+\.[\w.]+/, /\b\d{4}-\d{2}-\d{2}\b/].freeze

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.send_default_pii = false   # no request body, cookies, query string, or user IP
  config.include_local_variables = false
  config.breadcrumbs_logger = []
  config.before_send = lambda do |event, _hint|
    event.extra = {}
    event.exception&.values&.each do |exception|
      exception.value = PHI_PATTERNS.reduce(exception.value.to_s) { |text, re| text.gsub(re, "[FILTERED]") }
    end
    event
  end
end
