# Refuse to boot a non-production environment against a production database
# host (Solution 32).
module ProductionDataGuard
  class ProductionDatabaseError < StandardError; end

  PRODUCTION_HOST = /\Asummitcare-prod[-.]/

  def self.verify!(env: Rails.env,
                   configs: ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, include_hidden: true))
    return if env == "production"

    hosts = configs.filter_map { |config| config.host if config.respond_to?(:host) }
    offending = hosts.select { |host| host.to_s.match?(PRODUCTION_HOST) }
    return if offending.empty?

    raise ProductionDatabaseError,
          "#{env} is pointed at production database host(s): #{offending.join(', ')}"
  end
end

Rails.application.config.after_initialize { ProductionDataGuard.verify! }
