ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# No test talks to AWS (KMS, S3, Bedrock, SES, SNS, RDS): every SDK client
# returns stubbed responses. Tests that care about a call stub it explicitly.
Aws.config[:stub_responses] = true

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    SYNTHETIC_PASSWORD = "synthetic-test-password-2026" # test/fixtures/users.yml

    # Replaces a class method for the duration of the block. (Minitest 6 moved
    # Object#stub into the separate minitest-mock gem.)
    def with_class_method(klass, name, returning)
      original = klass.method(name)
      klass.define_singleton_method(name) { |*, **| returning }
      yield
    ensure
      klass.singleton_class.send(:remove_method, name)
      klass.define_singleton_method(name, original) unless klass.respond_to?(name)
    end
  end
end

class ActionDispatch::IntegrationTest
  # Starts a fresh DeviceSession for the user and returns its Authorization header.
  def auth_headers_for(user, device_id: SecureRandom.uuid)
    _session, tokens = DeviceSession.start!(user:, device_id:, device_name: "Test iPhone")
    { "Authorization" => "Bearer #{tokens[:access_token]}" }
  end
end
