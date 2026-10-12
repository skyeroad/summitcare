module VerifiesWebhookSignature
  extend ActiveSupport::Concern
  TOLERANCE_SECONDS = 300

  private

  def verify_webhook_signature!(partner)
    fields = request.headers["X-Webhook-Signature"].to_s.split(",").filter_map do |pair|
      key, value = pair.split("=", 2)
      [key, value] if value
    end.to_h
    timestamp = Integer(fields["t"].to_s, exception: false)
    fresh = timestamp && (Time.current.to_i - timestamp).abs <= TOLERANCE_SECONDS
    expected = OpenSSL::HMAC.hexdigest("SHA256", partner.webhook_secret, "#{timestamp}.#{request.raw_post}")
    unless fresh && ActiveSupport::SecurityUtils.secure_compare(expected, fields["v1"].to_s)
      head :unauthorized
    end
  end

  def first_delivery?(partner)
    WebhookReceipt.create!(partner: partner, event_id: request.headers["X-Webhook-Id"].presence || raise(ActionController::BadRequest))
    true
  rescue ActiveRecord::RecordNotUnique
    false
  end
end
