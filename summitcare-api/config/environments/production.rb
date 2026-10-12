require "active_support/core_ext/integer/time"
require_relative "../../lib/summit_care/wrapped_keys"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Documents live in the private, SSE-KMS S3 bucket (Solution 9).
  config.active_storage.service = :amazon
  config.active_storage.draw_routes = false

  # Active Record Encryption keys are wrapped by KMS (alias/summitcare-db) and
  # unwrapped once at boot (Solution 8). Development and test keys live in
  # per-environment credentials instead.
  config.active_record.encryption.primary_key =
    SummitCare::WrappedKeys.unwrap_list("AR_PRIMARY_KEYS_WRAPPED")
  config.active_record.encryption.deterministic_key =
    SummitCare::WrappedKeys.unwrap_list("AR_DETERMINISTIC_KEY_WRAPPED").first
  config.active_record.encryption.key_derivation_salt =
    SummitCare::WrappedKeys.unwrap_list("AR_KEY_DERIVATION_SALT_WRAPPED").first
  config.active_record.encryption.store_key_references = true

  # TLS ends at the ALB; trust X-Forwarded-Proto (Solution 10).
  config.assume_ssl = true
  config.force_ssl = true
  config.ssl_options = {
    hsts: { expires: 1.year, subdomains: true },
    redirect: { exclude: ->(request) { request.path == "/up" } }
  }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # No SQL statements or binds in production logs (Solution 15).
  config.log_level = :info

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "summitcare.example", protocol: "https" }

  # Generic, PHI-free notices through Amazon SES (Solution 24).
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: "email-smtp.us-east-1.amazonaws.com",
    port: 587,
    user_name: Rails.application.credentials.dig(:ses, :smtp_username),
    password: Rails.application.credentials.dig(:ses, :smtp_password),
    authentication: :login,
    enable_starttls: true
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [ "api.summitcare.example", "summitcare.example" ]
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
