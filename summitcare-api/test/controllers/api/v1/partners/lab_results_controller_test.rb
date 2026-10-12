require "test_helper"

class Api::V1::Partners::LabResultsControllerTest < ActionDispatch::IntegrationTest
  setup { @lab = partners(:cascade_reference_lab) }

  # The book's version sends no Authorization header. This controller authenticates the
  # partner credential first, so without one the signature check is never reached.
  test "rejects a stale signature" do
    body = { resourceType: "Bundle" }.to_json
    stale = 10.minutes.ago.to_i
    sig = OpenSSL::HMAC.hexdigest("SHA256", @lab.webhook_secret, "#{stale}.#{body}")
    post api_v1_partners_lab_results_path, params: body,
      headers: { "Content-Type" => "application/fhir+json", "X-Webhook-Id" => "evt_1",
                 "Authorization" => "Bearer #{PartnerCredential.issue!(partner: @lab, scopes: ["lab_results:write"])}",
                 "X-Webhook-Signature" => "t=#{stale},v1=#{sig}" }
    assert_response :unauthorized
  end

  # Not in the book: the accepted path, idempotency, and scopes.
  def deliver(body, event_id:, scopes: ["lab_results:write"])
    now = Time.current.to_i
    sig = OpenSSL::HMAC.hexdigest("SHA256", @lab.webhook_secret, "#{now}.#{body}")
    post api_v1_partners_lab_results_path, params: body,
      headers: { "Content-Type" => "application/fhir+json", "X-Webhook-Id" => event_id,
                 "Authorization" => "Bearer #{PartnerCredential.issue!(partner: @lab, scopes:)}",
                 "X-Webhook-Signature" => "t=#{now},v1=#{sig}" }
  end

  test "accepts a fresh, signed delivery once" do
    body = { resourceType: "Bundle", entry: [{ resource: {
      resourceType: "Observation", issued: "2026-10-12T09:00:00Z",
      subject: { identifier: { value: "SC-101442" } },
      code: { coding: [{ code: "2345-7", display: "Glucose" }] },
      valueQuantity: { value: 92, unit: "mg/dL" } } }] }.to_json

    assert_difference -> { patients(:riley).lab_results.count }, 1 do
      deliver(body, event_id: "evt_2")
      assert_response :accepted
      deliver(body, event_id: "evt_2")
      assert_response :ok
    end
  end

  test "a credential without the scope is refused" do
    deliver({ resourceType: "Bundle" }.to_json, event_id: "evt_3", scopes: ["lab_orders:read"])
    assert_response :not_found
  end
end
