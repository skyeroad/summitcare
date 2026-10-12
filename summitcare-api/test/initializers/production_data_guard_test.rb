require "test_helper"

class ProductionDataGuardTest < ActiveSupport::TestCase
  def config_for(host)
    ActiveRecord::DatabaseConfigurations::HashConfig.new(
      "staging", "primary", { adapter: "postgresql", host: host }
    )
  end

  test "refuses a production host outside production" do
    prod = config_for("summitcare-prod-primary.abc123.us-east-1.rds.amazonaws.com")
    assert_raises(ProductionDataGuard::ProductionDatabaseError) do
      ProductionDataGuard.verify!(env: "staging", configs: [prod])
    end
  end

  test "allows a staging host" do
    staging = config_for("summitcare-staging-primary.abc123.us-east-1.rds.amazonaws.com")
    assert_nil ProductionDataGuard.verify!(env: "staging", configs: [staging])
  end
end
