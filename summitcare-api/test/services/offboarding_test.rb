require "test_helper"

class OffboardingTest < ActiveSupport::TestCase
  test "offboarding closes every path to PHI" do
    okafor = users(:dr_okafor)
    Offboarding.call(user: okafor, performed_by: users(:morgan_reyes), reason: "Left the practice")

    okafor.reload
    assert okafor.deactivated_at
    assert_empty okafor.sessions
    assert okafor.device_sessions.all?(&:revoked_at)
    assert_empty CareTeamMembership.where(user: okafor).where("ends_on IS NULL OR ends_on > ?", Date.current)
    assert AuditEvent.exists?(subject_type: "User", subject_id: okafor.id, action: "update")
  end
end
