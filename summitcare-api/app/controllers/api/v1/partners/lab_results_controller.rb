# Inbound lab results from a partner laboratory (Solution 27). The partner
# authenticates with a scoped credential, then signs each delivery.
class Api::V1::Partners::LabResultsController < Api::V1::BaseController
  include VerifiesWebhookSignature
  allow_unauthenticated_access # partners are not users; see authenticate_partner!
  skip_before_action :load_break_glass_grant
  before_action :authenticate_partner!
  before_action -> { verify_webhook_signature!(@partner) }

  def create
    authorize @partner, :deliver_lab_results?
    return head(:ok) unless first_delivery?(@partner) # duplicate delivery: already processed

    bundle = JSON.parse(request.raw_post)
    results = Array(bundle["entry"]).filter_map { |entry| import(entry["resource"]) }
    Current.set(user: nil) do
      results.each { |result| AuditLog.record!(action: "create", subject: result, metadata: { partner_id: @partner.id }) }
    end
    head :accepted
  rescue JSON::ParserError
    head :bad_request
  end

  private

  def pundit_user = @credential

  def authenticate_partner!
    @credential = authenticate_with_http_token { |token, _| PartnerCredential.authenticate(token) }
    return head(:unauthorized) unless @credential
    @partner = @credential.partner
  end

  def import(resource)
    return unless resource&.dig("resourceType") == "Observation"
    patient = Patient.find_by(mrn: resource.dig("subject", "identifier", "value")) or return
    coding = resource.dig("code", "coding", 0) || {}
    patient.lab_results.create!(
      test_code: coding["code"], test_name: coding["display"],
      value: (resource.dig("valueQuantity", "value") || resource["valueString"]).to_s,
      unit: resource.dig("valueQuantity", "unit"),
      resulted_at: resource["issued"] || Time.current
    )
  end
end
