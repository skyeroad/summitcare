require "test_helper"

# Not in the book: Solutions 19 and 21 end to end.
class DisclosureTest < ActiveSupport::TestCase
  setup { @avery = patients(:avery) }

  def authorize!(**overrides)
    @avery.patient_authorizations.create!({ recipient: InsurerRecordsRelease::RECIPIENT,
      purpose: InsurerRecordsRelease::PURPOSE, information_scope: "Visit notes, 2025-2026",
      signed_at: 1.day.ago, expires_on: 1.year.from_now.to_date }.merge(overrides))
  end

  test "a release needs an active authorization and is logged but not accountable" do
    assert_raises(DisclosureGate::NotAuthorized) { InsurerRecordsRelease.call(patient: @avery) }

    authorization = authorize!
    disclosure = InsurerRecordsRelease.call(patient: @avery)
    assert_not disclosure.accountable
    assert AuditEvent.exists?(action: "disclose", patient_id: @avery.id)

    authorization.revoke!(written_revocation: { io: StringIO.new("%PDF-1.4 revocation"), filename: "revocation.pdf",
                                                content_type: "application/pdf" })
    assert_raises(DisclosureGate::NotAuthorized) { InsurerRecordsRelease.call(patient: @avery) }
  end

  test "public health reports appear in the accounting with the required fields" do
    stubs = Faraday::Adapter::Test::Stubs.new { |s| s.post("/lab-reports") { [202, { "Content-Type" => "application/json" }, "{}"] } }
    connection = HttpClient.for(:state_public_health, phi: true, url: StatePublicHealthClient::BASE_URL)
    connection.builder.adapter :test, stubs
    with_class_method(StatePublicHealthClient, :new, StatePublicHealthClient.new(connection:)) do
      PublicHealthReportJob.perform_now(lab_results(:avery_a1c))
    end

    rows = DisclosureAccounting.new(@avery).rows
    assert_equal 1, rows.size
    assert_equal ["State Department of Health, Epidemiology Division", "Public health"],
                 [rows.first.recipient, rows.first.purpose]
    assert rows.first.address.present? && rows.first.description.present?
  end
end
