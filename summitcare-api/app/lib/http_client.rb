module HttpClient
  def self.for(vendor_key, phi:, **faraday_options)
    vendor = VendorRegistry.fetch(vendor_key)
    Faraday.new(**faraday_options) do |f|
      f.use OutboundGuard, vendor: vendor, phi: phi
      f.request :json
      f.response :json
      f.response :raise_error
    end
  end
end
