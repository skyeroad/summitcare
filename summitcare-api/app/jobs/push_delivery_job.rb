# Push wake-up with generic text and an opaque message ID (Solutions 21 and 24).
# The push preference's destination holds the APNs device token.
class PushDeliveryJob < ApplicationJob
  def perform(preference, text, message = nil, client: ApnsClient.default)
    return if preference.destination.blank?

    payload = if message
      PushPayload.for_new_message(message, preference)
    else
      PushPayload.generic(text)
    end
    client.push(device_token: preference.destination, payload:)
  end
end
