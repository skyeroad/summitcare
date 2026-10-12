require "test_helper"

class OutboundGuardTest < ActiveSupport::TestCase
  test "refuses PHI calls to a vendor without a BAA" do
    conn = Faraday.new(url: "https://o1.ingest.us.sentry.io") do |f|
      f.use OutboundGuard, vendor: VendorRegistry.fetch(:sentry), phi: true
      f.adapter :test, Faraday::Adapter::Test::Stubs.new
    end
    assert_raises(OutboundGuard::UncoveredHostError) { conn.post("/api/1/envelope/") }
  end

  test "integrations build HTTP clients only through HttpClient" do
    offenders = Dir[Rails.root.join("app/**/*.rb")].reject { _1.end_with?("app/lib/http_client.rb") }
      .select { File.read(_1).match?(/Faraday\.new|Net::HTTP|HTTParty/) }
    assert_empty offenders
  end

  # Not in the book: the allowed path, and the host check.
  test "allows PHI to a BAA-covered host and refuses an unregistered host" do
    stubs = Faraday::Adapter::Test::Stubs.new { |s| s.get("/r4/Observation") { [200, { "Content-Type" => "application/json" }, "{}"] } }
    hie = VendorRegistry.fetch(:regional_hie)
    ok = Faraday.new(url: "https://fhir.regional-hie.example/r4/") do |f|
      f.use OutboundGuard, vendor: hie, phi: true
      f.adapter :test, stubs
    end
    assert_equal 200, ok.get("Observation").status

    elsewhere = Faraday.new(url: "https://fhir.other-hie.example/") do |f|
      f.use OutboundGuard, vendor: hie, phi: true
      f.adapter :test, stubs
    end
    assert_raises(OutboundGuard::UncoveredHostError) { elsewhere.get("/r4/Observation") }
  end
end
