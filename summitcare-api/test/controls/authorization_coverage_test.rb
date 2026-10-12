require "test_helper"

class AuthorizationCoverageTest < ActiveSupport::TestCase
  EXEMPT = {
    "SessionsController" => "staff console sign-in runs before there is a user to authorize",
    "Api::V1::SessionsController" => "sign-in runs before there is a user to authorize",
    "Api::V1::PasskeySessionsController" => "passkey sign-in runs before there is a user",
    "Api::V1::PasskeyRegistrationsController" => "acts only on Current.user's own credentials",
    "Api::V1::TokenRefreshesController" => "authenticated by refresh token, reads no records",
    "Api::V1::AnalyticsEventsController" => "anonymous product counts, reads no records"
  }.freeze

  test "every controller keeps verify_authorized" do
    Rails.application.eager_load!
    controllers = ApplicationController.descendants.reject { |c| c.abstract? || EXEMPT.key?(c.name) }
    missing = controllers.reject do |controller|
      controller._process_action_callbacks.any? { |cb| cb.kind == :after && cb.filter == :verify_authorized }
    end
    assert_empty missing.map(&:name), "Controllers that skip verify_authorized"
  end
end
