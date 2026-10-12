class OutboundGuard < Faraday::Middleware
  class UncoveredHostError < StandardError; end

  def on_request(env)
    vendor = options.fetch(:vendor)
    host = env.url.host
    unless vendor.covers_host?(host)
      raise UncoveredHostError, "#{host} is not registered for #{vendor.key}"
    end
    if options[:phi] && !vendor.phi_allowed?
      raise UncoveredHostError, "#{vendor.key} has no BAA on file; PHI call refused"
    end
  end
end
