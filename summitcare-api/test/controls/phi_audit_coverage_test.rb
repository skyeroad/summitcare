require "test_helper"

class PhiAuditCoverageTest < ActiveSupport::TestCase
  PHI_PATH = %r{\A/api/v1/patients}

  test "every action under /api/v1/patients declares audit_phi_access" do
    missing = Rails.application.routes.routes.filter_map do |route|
      next unless route.defaults[:controller] && route.path.spec.to_s.match?(PHI_PATH)

      controller = "#{route.defaults[:controller]}_controller".camelize.constantize
      action = route.defaults[:action]
      "#{controller.name}##{action}" unless controller.audited_phi_actions.include?(action)
    end.uniq
    assert_empty missing, "PHI routes without audit declarations:\n#{missing.join("\n")}"
  end
end
