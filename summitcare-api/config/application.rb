require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SummitcareApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Triggers and functions (the append-only audit table, Solution 13) only
    # survive in db/structure.sql, not db/schema.rb.
    config.active_record.schema_format = :sql

    # The staff console uses the authentication generator's cookie sessions
    # (Solution 1). API mode drops the middleware, so add back what it needs.
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore,
                          key: "_summitcare_console", same_site: :strict
    config.middleware.use ActionDispatch::Flash

    # Bedrock model for ClinicalAssistant (Solution 25). A model change is a
    # configuration change a reviewer can see.
    config.x.ai.model_id = ENV.fetch("BEDROCK_MODEL_ID", "example.bedrock-model-id-v1:0")

    # Short-lived document URLs in every environment (Solution 9). Set here, not
    # only in production.rb, because DocumentsController reads it and the
    # download test asserts it.
    config.active_storage.service_urls_expire_in = 1.minute

    # Whole-second ISO 8601 timestamps in JSON, which the iOS app's
    # JSONDecoder.dateDecodingStrategy = .iso8601 can parse (Solution 3).
    config.active_support.time_precision = 0
  end
end
