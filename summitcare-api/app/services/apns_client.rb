# Sends push payloads to the Apple Push Notification service (Solution 24).
#
# STUB: APNs requires HTTP/2 and a token-signed JWT from an Apple .p8 key. The
# companion code builds the request through HttpClient (so the vendor registry
# guards the host) but does not ship an HTTP/2 adapter or Apple credentials.
# Wire in an HTTP/2 Faraday adapter, or a gem such as apnotic, before production.
class ApnsClient
  HOST = "https://api.push.apple.com"
  TOPIC = "com.summitcare.app"

  def initialize(connection: nil)
    @connection = connection
  end

  def push(device_token:, payload:)
    raise NotImplementedError, "APNs delivery is not configured (see app/services/apns_client.rb)" unless @connection
    @connection.post("/3/device/#{device_token}", payload,
                     "apns-topic" => TOPIC, "apns-push-type" => "alert", "apns-priority" => "10")
  end

  def self.default = new
end
